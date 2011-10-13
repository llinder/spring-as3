/*
* Copyright 2007-2011 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
package org.springextensions.actionscript.context.impl {
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.async.operation.IOperationQueue;
	import org.as3commons.async.operation.event.OperationEvent;
	import org.as3commons.async.operation.impl.OperationQueue;
	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.eventbus.IEventBusAware;
	import org.as3commons.eventbus.IEventBusListener;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.ICloneable;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.util.OrderedUtils;
	import org.as3commons.reflect.Type;
	import org.as3commons.stageprocessing.IObjectSelector;
	import org.as3commons.stageprocessing.IStageObjectProcessor;
	import org.as3commons.stageprocessing.IStageObjectProcessorRegistry;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.context.config.IConfigurationPackage;
	import org.springextensions.actionscript.eventbus.EventBusShareKind;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistryAware;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.IObjectDestroyer;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessor;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessorAware;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.ITextFilesLoader;
	import org.springextensions.actionscript.ioc.config.impl.AsyncObjectDefinitionProviderResultOperation;
	import org.springextensions.actionscript.ioc.config.impl.TextFilesLoader;
	import org.springextensions.actionscript.ioc.config.impl.metadata.ILoaderInfoAware;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesParser;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;
	import org.springextensions.actionscript.ioc.config.property.impl.KeyValuePropertiesParser;
	import org.springextensions.actionscript.ioc.config.property.impl.Properties;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.PropertyPlaceholderConfigurerFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.ChildContextObjectDefinitionAccess;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.util.ContextUtils;
	import org.springextensions.actionscript.util.Environment;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class ApplicationContext extends EventDispatcher implements IApplicationContext, IDisposable, IAutowireProcessorAware, IEventBusAware, IEventBusUserRegistryAware, ILoaderInfoAware {

		private static const APPLICATION_CONTEXT_PROPERTIES_LOADER_NAME:String = "applicationContextTextFilesLoader";
		private static const DEFINITION_PROVIDER_QUEUE_NAME:String = "definitionProviderQueue";
		private static const GET_ASSOCIATED_FACTORY_METHOD_NAME:String = "getAssociatedFactory";
		private static const MXMODULES_MODULE_MANAGER_CLASS_NAME:String = "mx.modules.ModuleManager";
		private static const NEWLINE_CHAR:String = "\n";
		private static const OBJECT_FACTORY_POST_PROCESSOR_QUEUE_NAME:String = "objectFactoryPostProcessorQueue";

		/**
		 * Creates a new <code>ApplicationContext</code> instance.
		 */
		public function ApplicationContext(parent:IApplicationContext=null, rootViews:Vector.<DisplayObject>=null, objFactory:IObjectFactory=null) {
			super();
			objectFactory = objFactory;
			_definitionProviders = new Vector.<IObjectDefinitionsProvider>();
			_rootViews = rootViews ||= new Vector.<DisplayObject>();
			applicationDomain = resolveRootViewApplicationDomain(_rootViews);
			loaderInfo = resolveRootViewLoaderInfo(_rootViews);
		}

		protected var objectFactory:IObjectFactory;
		private var _childContexts:Vector.<IApplicationContext>;
		private var _definitionProviders:Vector.<IObjectDefinitionsProvider>;
		private var _eventBus:IEventBus;
		private var _isDisposed:Boolean;
		private var _loaderInfo:LoaderInfo;
		private var _objectFactoryPostProcessors:Vector.<IObjectFactoryPostProcessor>;
		private var _operationQueue:IOperationQueue;
		private var _propertiesParser:IPropertiesParser;
		private var _rootViews:Vector.<DisplayObject>;
		private var _stageProcessorRegistry:IStageObjectProcessorRegistry;
		private var _textFilesLoader:ITextFilesLoader;
		private var _token:uint;

		/**
		 * @inheritDoc
		 */
		public function get applicationDomain():ApplicationDomain {
			return (objectFactory != null) ? objectFactory.applicationDomain : Type.currentApplicationDomain;
		}

		/**
		 * @private
		 */
		public function set applicationDomain(value:ApplicationDomain):void {
			if (objectFactory != null) {
				objectFactory.applicationDomain = value;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get autowireProcessor():IAutowireProcessor {
			return (objectFactory is IAutowireProcessorAware) ? IAutowireProcessorAware(objectFactory).autowireProcessor : null;
		}

		/**
		 * @private
		 */
		public function set autowireProcessor(value:IAutowireProcessor):void {
			if (objectFactory is IAutowireProcessorAware) {
				IAutowireProcessorAware(objectFactory).autowireProcessor = value;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get cache():IInstanceCache {
			return objectFactory.cache;
		}

		/**
		 * @inheritDoc
		 */
		public function get childContexts():Vector.<IApplicationContext> {
			return _childContexts;
		}

		/**
		 * @inheritDoc
		 */
		public function get definitionProviders():Vector.<IObjectDefinitionsProvider> {
			return _definitionProviders;
		}

		/**
		 * @inheritDoc
		 */
		public function get dependencyInjector():IDependencyInjector {
			return objectFactory.dependencyInjector;
		}

		/**
		 * @private
		 */
		public function set dependencyInjector(value:IDependencyInjector):void {
			objectFactory.dependencyInjector = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get eventBus():IEventBus {
			return (objectFactory is IEventBusAware) ? IEventBusAware(objectFactory).eventBus : _eventBus;
		}

		/**
		 * @private
		 */
		public function set eventBus(value:IEventBus):void {
			if (objectFactory is IEventBusAware) {
				IEventBusAware(objectFactory).eventBus = value;
			} else {
				_eventBus = value;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get eventBusUserRegistry():IEventBusUserRegistry {
			if (objectFactory is IEventBusUserRegistryAware) {
				return IEventBusUserRegistryAware(objectFactory).eventBusUserRegistry;
			}
			return null;
		}

		/**
		 * @private
		 */
		public function set eventBusUserRegistry(value:IEventBusUserRegistry):void {
			if (objectFactory is IEventBusUserRegistryAware) {
				IEventBusUserRegistryAware(objectFactory).eventBusUserRegistry = value;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		/**
		 * @inheritDoc
		 */
		public function get isReady():Boolean {
			return objectFactory.isReady;
		}

		/**
		 * @private
		 */
		public function set isReady(value:Boolean):void {
			objectFactory.isReady = true;
		}

		/**
		 * @inheritDoc
		 */
		public function get loaderInfo():LoaderInfo {
			return _loaderInfo;
		}

		/**
		 * @private
		 */
		public function set loaderInfo(value:LoaderInfo):void {
			_loaderInfo = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return objectFactory.objectDefinitionRegistry;
		}

		/**
		 * @private
		 */
		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			objectFactory.objectDefinitionRegistry = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectDestroyer():IObjectDestroyer {
			return objectFactory.objectDestroyer;
		}

		/**
		 * @private
		 */
		public function set objectDestroyer(value:IObjectDestroyer):void {
			objectFactory.objectDestroyer = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectFactoryPostProcessors():Vector.<IObjectFactoryPostProcessor> {
			return _objectFactoryPostProcessors ||= new Vector.<IObjectFactoryPostProcessor>();
		}

		/**
		 * @inheritDoc
		 */
		public function get objectPostProcessors():Vector.<IObjectPostProcessor> {
			return objectFactory.objectPostProcessors;
		}

		/**
		 * @inheritDoc
		 */
		public function get parent():IObjectFactory {
			return objectFactory.parent;
		}

		/**
		 * @private
		 */
		public function set parent(value:IObjectFactory):void {
			objectFactory.parent = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get propertiesParser():IPropertiesParser {
			return _propertiesParser;
		}

		/**
		 * @private
		 */
		public function set propertiesParser(value:IPropertiesParser):void {
			_propertiesParser = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get propertiesProvider():IPropertiesProvider {
			return objectFactory.propertiesProvider;
		}

		/**
		 * @private
		 */
		public function set propertiesProvider(value:IPropertiesProvider):void {
			objectFactory.propertiesProvider = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get referenceResolvers():Vector.<IReferenceResolver> {
			return objectFactory.referenceResolvers;
		}

		/**
		 * @inheritDoc
		 */
		public function get rootViews():Vector.<DisplayObject> {
			return _rootViews;
		}

		/**
		 * @inheritDoc
		 */
		public function get stageProcessorRegistry():IStageObjectProcessorRegistry {
			return _stageProcessorRegistry;
		}

		/**
		 * @private
		 */
		public function set stageProcessorRegistry(value:IStageObjectProcessorRegistry):void {
			_stageProcessorRegistry = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get textFilesLoader():ITextFilesLoader {
			return _textFilesLoader;
		}

		/**
		 * @private
		 */
		public function set textFilesLoader(value:ITextFilesLoader):void {
			_textFilesLoader = value;
		}

		/**
		 * @inheritDoc
		 */
		public function addChildContext(childContext:IApplicationContext, shareDefinitions:Boolean=true, shareSingletons:Boolean=true, shareEventBus:EventBusShareKind=null):IApplicationContext {
			if (childContext !== this) {
				shareEventBus ||= EventBusShareKind.BOTH_WAYS;
				_childContexts ||= new Vector.<IApplicationContext>();
				if (_childContexts.indexOf(childContext) < 0) {
					childContexts[childContexts.length] = childContext;
					if (shareEventBus !== EventBusShareKind.NONE) {
						addChildContextEventBusListener(childContext, eventBus, shareEventBus);
					}
					if (shareDefinitions) {
						addDefinitionsToChildContext(childContext, objectDefinitionRegistry);
					}
					if (shareSingletons) {
						addSingletonsToChildContext(childContext, cache, objectDefinitionRegistry);
					}
				}
			}
			return this;
		}

		/**
		 * @inheritDoc
		 */
		public function addDefinitionProvider(provider:IObjectDefinitionsProvider):IApplicationContext {
			if (definitionProviders.indexOf(provider < 0)) {
				if (provider is IApplicationDomainAware) {
					IApplicationDomainAware(provider).applicationDomain = applicationDomain;
				}
				if (provider is IApplicationContextAware) {
					IApplicationContextAware(provider).applicationContext = this;
				}
				definitionProviders[definitionProviders.length] = provider;
			}
			return this;
		}

		/**
		 * @inheritDoc
		 */
		public function addObjectFactoryPostProcessor(objectFactoryPostProcessor:IObjectFactoryPostProcessor):IApplicationContext {
			if (objectFactoryPostProcessors.indexOf(objectFactoryPostProcessor) < 0) {
				if (objectFactoryPostProcessor is IApplicationDomainAware) {
					IApplicationDomainAware(objectFactoryPostProcessor).applicationDomain = applicationDomain;
				}
				objectFactoryPostProcessors[objectFactoryPostProcessors.length] = objectFactoryPostProcessor;
				_objectFactoryPostProcessors.sort(OrderedUtils.orderedCompareFunction);
			}
			return this;
		}

		/**
		 * @inheritDoc
		 */
		public function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):IObjectFactory {
			return objectFactory.addObjectPostProcessor(objectPostProcessor);
		}

		/**
		 * @inheritDoc
		 */
		public function addReferenceResolver(referenceResolver:IReferenceResolver):IObjectFactory {
			return objectFactory.addReferenceResolver(referenceResolver);
		}

		/**
		 * @inheritDoc
		 */
		public function addRootView(rootView:DisplayObject):void {
			rootViews[rootViews.length] = rootView;
			if ((objectFactory.isReady) && (rootViews.length > 1) && (stageProcessorRegistry != null)) {
				var processors:Vector.<IStageObjectProcessor> = stageProcessorRegistry.getStageProcessorsByRootView(rootViews[0]);
				for each (var processor:IStageObjectProcessor in processors) {
					var selectors:Vector.<IObjectSelector> = stageProcessorRegistry.getObjectSelectorsForStageProcessor(processor);
					for each (var selector:IObjectSelector in selectors) {
						stageProcessorRegistry.registerStageObjectProcessor(processor, selector, rootView);
					}
				}
			}
		}

		public function canCreate(objectName:String):Boolean {
			return objectFactory.canCreate(objectName);
		}

		/**
		 * @inheritDoc
		 */
		public function configure(configurationPackage:IConfigurationPackage):IApplicationContext {
			configurationPackage.execute(this);
			return this;
		}

		/**
		 * @inheritDoc
		 */
		public function createInstance(clazz:Class, constructorArguments:Array=null):* {
			return objectFactory.createInstance(clazz, constructorArguments);
		}

		/**
		 * @inheritDoc
		 */
		public function destroyObject(instance:Object):void {
			objectFactory.destroyObject(instance);
		}

		/**
		 * Clears, disposes and nulls out every member of the current <code>ApplicationContext</code>.
		 */
		public function dispose():void {
			if (!_isDisposed) {
				try {
					ContextUtils.disposeInstance(_textFilesLoader);
					_textFilesLoader = null;

					ContextUtils.disposeInstance(objectFactory);
					objectFactory = null;

					_definitionProviders = null;

					if (_eventBus != null) {
						_eventBus.clear();
					}
					ContextUtils.disposeInstance(_eventBus);
					_eventBus = null;

					_operationQueue = null;
					_rootViews = null;

					if (_stageProcessorRegistry != null) {
						_stageProcessorRegistry.clear();
					}
					ContextUtils.disposeInstance(_stageProcessorRegistry);
					_stageProcessorRegistry = null;
					for each (var factoryPostProcessor:IObjectFactoryPostProcessor in _objectFactoryPostProcessors) {
						ContextUtils.disposeInstance(factoryPostProcessor);
					}
					_objectFactoryPostProcessors = null;
				} finally {
					_isDisposed = true;
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		public function getObject(name:String, constructorArguments:Array=null):* {
			return objectFactory.getObject(name, constructorArguments);
		}

		/**
		 * @inheritDoc
		 */
		public function getObjectDefinition(objectName:String):IObjectDefinition {
			return objectFactory.getObjectDefinition(objectName);
		}

		/**
		 *
		 */
		public function load():void {
			if (!isReady) {
				_operationQueue = new OperationQueue(DEFINITION_PROVIDER_QUEUE_NAME);
				for each (var provider:IObjectDefinitionsProvider in definitionProviders) {
					var operation:IOperation = provider.createDefinitions();
					if (operation != null) {
						operation.addCompleteListener(providerCompleteHandler, false, 0, true);
						_operationQueue.addOperation(operation);
					} else {
						handleObjectDefinitionResult(provider);
					}
				}
				if (_operationQueue.total > 0) {
					_operationQueue.addCompleteListener(providersLoadedHandler);
					_operationQueue.addErrorListener(providersLoadErrorHandler);
				} else {
					_operationQueue = null;
					cleanUpObjectDefinitionCreation();
				}
			}
		}

		public function removeChildContext(childContext:IApplicationContext):IApplicationContext {
			var idx:int = _childContexts.indexOf(childContext);
			if (idx > -1) {
				_childContexts.splice(idx, 1);
				if ((eventBus is IEventBusListener) && (childContext is IEventBusAware) && (IEventBusAware(childContext).eventBus != null)) {
					IEventBusAware(childContext).eventBus.removeListener(eventBus as IEventBusListener);
				}
				if ((childContext is IEventBusAware) && (IEventBusAware(childContext).eventBus is IEventBusListener) && (eventBus != null)) {
					eventBus.removeListener(IEventBusAware(childContext).eventBus as IEventBusListener);
				}
			}
			return this;
		}

		/**
		 * @inheritDoc
		 */
		public function removeRootView(rootView:DisplayObject):void {
			var idx:int = rootViews.indexOf(rootView);
			if (idx > -1) {
				rootViews.splice(idx, 1);
				var processors:Vector.<IStageObjectProcessor> = stageProcessorRegistry.getStageProcessorsByRootView(rootView);
				for each (var processor:IStageObjectProcessor in processors) {
					var selectors:Vector.<IObjectSelector> = stageProcessorRegistry.getObjectSelectorsForStageProcessor(processor);
					for each (var selector:IObjectSelector in selectors) {
						stageProcessorRegistry.unregisterStageObjectProcessor(processor, selector, rootView);
					}
				}
			}
		}

		/**
		 * @private
		 */
		public function resolveReference(property:*):* {
			return objectFactory.resolveReference(property);
		}

		/**
		 *
		 * @param references
		 * @return
		 */
		public function resolveReferences(references:Array):Array {
			return objectFactory.resolveReferences(references);
		}

		/**
		 *
		 * @param childContext
		 * @param parentEventBus
		 */
		protected function addChildContextEventBusListener(childContext:IApplicationContext, parentEventBus:IEventBus, kind:EventBusShareKind):void {
			if ((childContext is IEventBusAware) && (IEventBusAware(childContext).eventBus is IEventBusListener)) {
				var childEventBus:IEventBus = IEventBusAware(childContext).eventBus;
				switch (kind) {
					case EventBusShareKind.BOTH_WAYS:
						linkEventBuses(parentEventBus, childEventBus);
						linkEventBuses(childEventBus, parentEventBus);
						break;
					case EventBusShareKind.PARENT_LISTENS_TO_CHILD:
						linkEventBuses(childEventBus, parentEventBus);
						break;
					case EventBusShareKind.CHILD_LISTENS_TO_PARENT:
						linkEventBuses(parentEventBus, childEventBus);
						break;
				}
			}
		}

		/**
		 *
		 * @param childContext
		 * @param objectDefinitionRegistry
		 */
		protected function addDefinitionsToChildContext(childContext:IApplicationContext, objectDefinitionRegistry:IObjectDefinitionRegistry):void {
			var definitionNames:Vector.<String> = objectDefinitionRegistry.objectDefinitionNames;
			for each (var objectName:String in definitionNames) {
				if (!childContext.objectDefinitionRegistry.containsObjectDefinition(objectName)) {
					var od:IObjectDefinition = objectDefinitionRegistry.getObjectDefinition(objectName);
					if ((od.childContextAccess === ChildContextObjectDefinitionAccess.DEFINITION) || (od.childContextAccess === ChildContextObjectDefinitionAccess.FULL)) {
						if (od is ICloneable) {
							childContext.objectDefinitionRegistry.registerObjectDefinition(objectName, ICloneable(od).clone());
						}
					}
				}
			}
		}

		/**
		 *
		 * @param childContext
		 * @param cache
		 * @param objectDefinitionRegistry
		 */
		protected function addSingletonsToChildContext(childContext:IApplicationContext, cache:IInstanceCache, objectDefinitionRegistry:IObjectDefinitionRegistry):void {
			var cacheNames:Vector.<String> = cache.getCachedNames();
			for each (var objectName:String in cacheNames) {
				var share:Boolean = true;
				if (objectDefinitionRegistry.containsObjectDefinition(objectName)) {
					var od:IObjectDefinition = objectDefinitionRegistry.getObjectDefinition(objectName);
					share = ((od.childContextAccess === ChildContextObjectDefinitionAccess.SINGLETON) || (od.childContextAccess === ChildContextObjectDefinitionAccess.FULL));
				}
				if ((share) && (!childContext.cache.hasInstance(objectName))) {
					childContext.cache.addInstance(objectName, cache.getInstance(objectName));
				}
			}
		}

		/**
		 *
		 * @param _operationQueue
		 */
		protected function cleanQueueAfterDefinitionProviders(queue:IOperationQueue):void {
			queue.removeCompleteListener(providersLoadedHandler);
			queue.removeErrorListener(providersLoadErrorHandler);
		}

		/**
		 *
		 */
		protected function cleanUpObjectDefinitionCreation():void {
			if ((propertiesProvider != null) && (propertiesProvider.length > 0)) {
				var placeholderConfig:PropertyPlaceholderConfigurerFactoryPostProcessor = new PropertyPlaceholderConfigurerFactoryPostProcessor(0);
				placeholderConfig.properties = propertiesProvider;
				addObjectFactoryPostProcessor(placeholderConfig);
			}
			ContextUtils.disposeInstance(_propertiesParser);
			_propertiesParser = null;
			for each (var definitionProvider:IObjectDefinitionsProvider in _definitionProviders) {
				if (definitionProvider is IDisposable) {
					ContextUtils.disposeInstance(definitionProvider);
				}
			}
			_definitionProviders.length = 0;
			_definitionProviders = null;
			_operationQueue = null;
			ContextUtils.disposeInstance(_textFilesLoader);
			_textFilesLoader = null;
			objectFactory.isReady = true;
			executeObjectFactoryPostProcessors();
		}

		/**
		 * Dispatches the <code>Event.COMPLETE</code> after the current <code>ApplicationContext</code> has been fully initialized.
		 *
		 */
		protected function completeContextInitialization():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}

		/**
		 *
		 * @return
		 */
		protected function createTextFilesLoader():ITextFilesLoader {
			var textFilesLoader:ITextFilesLoader = new TextFilesLoader(APPLICATION_CONTEXT_PROPERTIES_LOADER_NAME);
			textFilesLoader.addCompleteListener(propertyTextFilesLoadComplete, false, 0, true);
			_operationQueue.addOperation(textFilesLoader);
			return textFilesLoader;
		}

		/**
		 *
		 */
		protected function executeObjectFactoryPostProcessors():void {
			_operationQueue = new OperationQueue(OBJECT_FACTORY_POST_PROCESSOR_QUEUE_NAME);
			for each (var postprocessor:IObjectFactoryPostProcessor in objectFactoryPostProcessors) {
				var operation:IOperation = postprocessor.postProcessObjectFactory(this);
				if (operation != null) {
					_operationQueue.addOperation(operation);
				}
			}
			if (_operationQueue.total > 0) {
				_operationQueue.addCompleteListener(handleObjectFactoriesComplete, false, 0, true);
				_operationQueue.addErrorListener(handleObjectFactoriesError, false, 0, true);
			} else {
				finalizeObjectFactoryProcessorExecution();
			}
		}

		/**
		 *
		 */
		protected function finalizeObjectFactoryProcessorExecution():void {
			for each (var postprocessor:IObjectFactoryPostProcessor in objectFactoryPostProcessors) {
				ContextUtils.disposeInstance(postprocessor);
			}
			_objectFactoryPostProcessors.length = 0;
			_objectFactoryPostProcessors = null;
			instantiateSingletons();
			completeContextInitialization();
		}

		/**
		 *
		 * @param objectDefinitionsProvider
		 */
		protected function handleObjectDefinitionResult(objectDefinitionsProvider:IObjectDefinitionsProvider):void {
			registerObjectDefinitions(objectDefinitionsProvider.objectDefinitions);
			if (objectDefinitionsProvider.propertyURIs != null) {
				loadPropertyURIs(objectDefinitionsProvider.propertyURIs);
			}
			if ((objectDefinitionsProvider.propertiesProvider != null) && (objectDefinitionsProvider.propertiesProvider.length > 0)) {
				propertiesProvider ||= new Properties();
				propertiesProvider.merge(objectDefinitionsProvider.propertiesProvider);
			}
		}

		/**
		 *
		 * @param result
		 */
		protected function handleObjectFactoriesComplete(result:*):void {
			finalizeObjectFactoryProcessorExecution();
		}

		/**
		 *
		 * @param error
		 */
		protected function handleObjectFactoriesError(error:*):void {
		}

		/**
		 *
		 */
		protected function instantiateSingletons():void {
			var names:Vector.<String> = objectFactory.objectDefinitionRegistry.getSingletons();
			for each (var name:String in names) {
				if (!objectFactory.cache.hasInstance(name)) {
					objectFactory.getObject(name);
				}
			}
		}

		protected function linkEventBuses(source:IEventBus, destination:IEventBus):void {
			if (destination is IEventBusListener) {
				source.addListener(destination as IEventBusListener);
			}
		}

		/**
		 *
		 * @param propertyURIs
		 */
		protected function loadPropertyURIs(propertyURIs:Vector.<TextFileURI>):void {
			_textFilesLoader ||= createTextFilesLoader();
			_textFilesLoader.addURIs(propertyURIs);
		}

		/**
		 *
		 * @param propertySources
		 */
		protected function propertyTextFilesLoadComplete(operationEvent:OperationEvent):void {
			var propertySources:Vector.<String> = operationEvent.result as Vector.<String>;
			if (propertySources != null) {
				var source:String = propertySources.join(NEWLINE_CHAR);
				propertiesParser ||= new KeyValuePropertiesParser();
				propertiesProvider ||= new Properties();
				propertiesParser.parseProperties(source, propertiesProvider);
			}
		}

		/**
		 *
		 * @param event
		 */
		protected function providerCompleteHandler(event:OperationEvent):void {
			handleObjectDefinitionResult(AsyncObjectDefinitionProviderResultOperation(event.operation).objectDefinitionsProvider);
		}

		/**
		 *
		 * @param error
		 */
		protected function providersLoadErrorHandler(error:*):void {
			cleanQueueAfterDefinitionProviders(_operationQueue);
			throw new Error("Not implemented yet");
		}

		/**
		 *
		 * @param operationEvent
		 */
		protected function providersLoadedHandler(operationEvent:OperationEvent):void {
			cleanQueueAfterDefinitionProviders(_operationQueue);
			cleanUpObjectDefinitionCreation();
		}

		/**
		 *
		 * @param newObjectDefinitions
		 */
		protected function registerObjectDefinitions(newObjectDefinitions:Object):void {
			if (objectDefinitionRegistry != null) {
				for (var name:String in newObjectDefinitions) {
					objectDefinitionRegistry.registerObjectDefinition(name, newObjectDefinitions[name]);
				}
			}
		}

		protected function resolveRootViewApplicationDomain(views:Vector.<DisplayObject>):ApplicationDomain {
			if ((views != null) && (views.length > 0)) {
				try {
					var cls:Class = ClassUtils.forName(MXMODULES_MODULE_MANAGER_CLASS_NAME, applicationDomain);
					var factory:Object = cls[GET_ASSOCIATED_FACTORY_METHOD_NAME](views[0]);
					if (factory != null) {
						return ApplicationDomain(factory.info().currentDomain);
					}
				} catch (e:Error) {
				}
			}
			return Type.currentApplicationDomain;
		}

		protected function resolveRootViewLoaderInfo(views:Vector.<DisplayObject>):LoaderInfo {
			var loaderInfo:LoaderInfo;
			if ((views == null) || (views.length == 0)) {
				var stage:Stage = Environment.getCurrentStage();
				if (stage != null) {
					loaderInfo = stage.loaderInfo;
				}
			} else {
				loaderInfo = views[0].loaderInfo;
			}
			if (loaderInfo == null) {
				waitForLoaderInfo();
			}
			return loaderInfo;
		}

		protected function waitForLoaderInfo():void {
			_token = setTimeout(function():void {
				if (_loaderInfo == null) {
					clearTimeout(_token);
					_loaderInfo = resolveRootViewLoaderInfo(_rootViews);
				}
			}, 100);
		}
	}
}
