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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.async.operation.IOperationQueue;
	import org.as3commons.async.operation.event.OperationEvent;
	import org.as3commons.async.operation.impl.OperationQueue;
	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.eventbus.IEventBusAware;
	import org.as3commons.eventbus.impl.EventBus;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.stageprocessing.IStageObjectProcessorRegistry;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.ITextFilesLoader;
	import org.springextensions.actionscript.ioc.config.impl.AsyncObjectDefinitionProviderResult;
	import org.springextensions.actionscript.ioc.config.impl.TextFilesLoader;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesParser;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;
	import org.springextensions.actionscript.ioc.config.property.impl.KeyValuePropertiesParser;
	import org.springextensions.actionscript.ioc.config.property.impl.Properties;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ArrayCollectionReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ArrayReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.DictionaryReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ObjectReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ThisReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.VectorReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.RegisterObjectPostProcessorsFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.impl.DefaultDependencyInjector;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.util.ContextUtils;

	[Event(name="complete", type="flash.events.Event")]
	/**
	 *
	 * @author Roland Zwaga
	 */
	public class ApplicationContext extends EventDispatcher implements IApplicationContext, IDisposable {

		private static const APPLICATION_CONTEXT_PROPERTIES_LOADER_NAME:String = "applicationContextTextFilesLoader";
		private static const DEFINITION_PROVIDER_QUEUE_NAME:String = "definitionProviderQueue";
		private static const NEWLINE_CHAR:String = "\n";
		private static const OBJECT_FACTORY_POST_PROCESSOR_QUEUE_NAME:String = "objectFactoryPostProcessorQueue";
		private static const MXMODULES_MODULE_MANAGER_CLASS_NAME:String = "mx.modules.ModuleManager";
		private static const GET_ASSOCIATED_FACTORY_METHOD_NAME:String = "getAssociatedFactory";

		/**
		 * Creates a new <code>ApplicationContext</code> instance.
		 * @param parent
		 * @param objFactory
		 */
		public function ApplicationContext(parent:IApplicationContext=null, rootView:DisplayObject=null, objFactory:IObjectFactory=null) {
			super();
			initApplicationContext(parent, rootView, objFactory);
		}

		private var _definitionProviders:Vector.<IObjectDefinitionsProvider>;
		private var _eventBus:IEventBus;
		private var _isDisposed:Boolean;
		private var _objectFactory:IObjectFactory;
		private var _operationQueue:IOperationQueue;
		private var _textFilesLoader:ITextFilesLoader;
		private var _propertiesParser:IPropertiesParser;
		private var _rootView:DisplayObject;
		private var _stageProcessorRegistry:IStageObjectProcessorRegistry;

		/**
		 * @inheritDoc
		 */
		public function get applicationDomain():ApplicationDomain {
			return _objectFactory.applicationDomain;
		}

		/**
		 * @private
		 */
		public function set applicationDomain(value:ApplicationDomain):void {
			_objectFactory.applicationDomain = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get cache():IInstanceCache {
			return _objectFactory.cache;
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
			return _objectFactory.dependencyInjector;
		}

		/**
		 * @private
		 */
		public function set dependencyInjector(value:IDependencyInjector):void {
			_objectFactory.dependencyInjector = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get eventBus():IEventBus {
			return (_objectFactory is IEventBusAware) ? IEventBusAware(_objectFactory).eventBus : _eventBus;
		}

		/**
		 * @private
		 */
		public function set eventBus(value:IEventBus):void {
			if (_objectFactory is IEventBusAware) {
				IEventBusAware(_objectFactory).eventBus = value;
			} else {
				_eventBus = value;
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
			return _objectFactory.isReady;
		}

		/**
		 * @private
		 */
		public function set isReady(value:Boolean):void {
			_objectFactory.isReady = true;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectFactory.objectDefinitionRegistry;
		}

		/**
		 * @private
		 */
		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_objectFactory.objectDefinitionRegistry = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectFactoryPostProcessors():Vector.<IObjectFactoryPostProcessor> {
			return _objectFactory.objectFactoryPostProcessors;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectPostProcessors():Vector.<IObjectPostProcessor> {
			return _objectFactory.objectPostProcessors;
		}

		/**
		 * @inheritDoc
		 */
		public function get parent():IObjectFactory {
			return _objectFactory.parent;
		}

		/**
		 * @private
		 */
		public function set parent(value:IObjectFactory):void {
			_objectFactory.parent = value;
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
			return _objectFactory.propertiesProvider;
		}

		/**
		 * @private
		 */
		public function set propertiesProvider(value:IPropertiesProvider):void {
			_objectFactory.propertiesProvider = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get referenceResolvers():Vector.<IReferenceResolver> {
			return _objectFactory.referenceResolvers;
		}

		/**
		 * @inheritDoc
		 */
		public function get rootView():DisplayObject {
			return _rootView;
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
		public function addDefinitionProvider(provider:IObjectDefinitionsProvider):void {
			if (provider is IApplicationDomainAware) {
				IApplicationDomainAware(provider).applicationDomain = applicationDomain;
			}
			definitionProviders[definitionProviders.length] = provider;
		}

		/**
		 * @inheritDoc
		 */
		public function addObjectFactoryPostProcessor(objectFactoryPostProcessor:IObjectFactoryPostProcessor):void {
			_objectFactory.addObjectFactoryPostProcessor(objectFactoryPostProcessor);
		}

		/**
		 * @inheritDoc
		 */
		public function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):void {
			_objectFactory.addObjectPostProcessor(objectPostProcessor);
		}

		/**
		 * @inheritDoc
		 */
		public function addReferenceResolver(referenceResolver:IReferenceResolver):void {
			_objectFactory.addReferenceResolver(referenceResolver);
		}

		/**
		 * @inheritDoc
		 */
		public function createInstance(clazz:Class, constructorArguments:Array=null):* {
			return _objectFactory.createInstance(clazz, constructorArguments);
		}

		/**
		 * Clears, disposes and nulls out every member of the current <code>ApplicationContext</code>.
		 */
		public function dispose():void {
			if (!_isDisposed) {
				try {
					ContextUtils.disposeInstance(_textFilesLoader);
					_textFilesLoader = null;

					ContextUtils.disposeInstance(_objectFactory);
					_objectFactory = null;

					_definitionProviders = null;

					if (_eventBus != null) {
						_eventBus.clear();
					}
					ContextUtils.disposeInstance(_eventBus);
					_eventBus = null;

					_operationQueue = null;
					_rootView = null;

					if (_stageProcessorRegistry != null) {
						_stageProcessorRegistry.clear();
					}
					ContextUtils.disposeInstance(_stageProcessorRegistry);
					_stageProcessorRegistry = null;
				} finally {
					_isDisposed = true;
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		public function getObject(name:String, constructorArguments:Array=null):* {
			return _objectFactory.getObject(name, constructorArguments);
		}

		/**
		 * @inheritDoc
		 */
		public function getObjectDefinition(objectName:String):IObjectDefinition {
			return _objectFactory.getObjectDefinition(objectName);
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
						handleObjectDefinitionResult(provider.objectDefinitions, provider.propertiesProvider, provider.propertyURIs);
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

		protected function handleObjectDefinitionResult(objectDefinitions:Object, propertiesProvider:IPropertiesProvider, propertyURIs:Vector.<TextFileURI>):void {
			registerObjectDefinitions(objectDefinitions);
			if (propertyURIs != null) {
				loadPropertyURIs(propertyURIs);
			}
			if (propertiesProvider != null) {
				propertiesProvider.merge(propertiesProvider);
			}
		}

		/**
		 * @private
		 */
		public function resolveReference(property:*):* {
			return _objectFactory.resolveReference(property);
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
				//addObjectFactoryPostProcessor(
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
			_objectFactory.isReady = true;
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
		 * @param parent
		 * @return
		 */
		protected function createDefaultObjectFactory(parent:IApplicationContext):IObjectFactory {
			var defaultObjectFactory:DefaultObjectFactory = new DefaultObjectFactory(parent);
			defaultObjectFactory.eventBus = new EventBus();
			defaultObjectFactory.dependencyInjector = new DefaultDependencyInjector();
			var autowireProcessor:DefaultAutowireProcessor = new DefaultAutowireProcessor(this);
			defaultObjectFactory.autowireProcessor = autowireProcessor;
			return defaultObjectFactory;
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
			if (!isReady) {
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
		}

		/**
		 *
		 */
		protected function finalizeObjectFactoryProcessorExecution():void {
			instantiateSingletons();
			completeContextInitialization();
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
		 * @param parent
		 * @param rootView
		 * @param objFactory
		 */
		protected function initApplicationContext(parent:IApplicationContext, rootView:DisplayObject, objFactory:IObjectFactory):void {
			_definitionProviders = new Vector.<IObjectDefinitionsProvider>();
			_objectFactory = objFactory ||= createDefaultObjectFactory(parent);
			_rootView = rootView;
			resolveRootViewApplicationDomain(_rootView);

			_objectFactory.addObjectFactoryPostProcessor(new RegisterObjectPostProcessorsFactoryPostProcessor());

			_objectFactory.addReferenceResolver(new ThisReferenceResolver(this));
			_objectFactory.addReferenceResolver(new ObjectReferenceResolver(this));
			_objectFactory.addReferenceResolver(new ArrayReferenceResolver(this));
			_objectFactory.addReferenceResolver(new DictionaryReferenceResolver(this));
			_objectFactory.addReferenceResolver(new VectorReferenceResolver(this));
			if (ArrayCollectionReferenceResolver.canCreate(applicationDomain)) {
				_objectFactory.addReferenceResolver(new ArrayCollectionReferenceResolver(this));
			}
		}

		protected function resolveRootViewApplicationDomain(_rootView:DisplayObject):void {
			try {
				var cls:Class = ClassUtils.forName(MXMODULES_MODULE_MANAGER_CLASS_NAME, applicationDomain);
				var factory:Object = cls[GET_ASSOCIATED_FACTORY_METHOD_NAME](_rootView);
				if (factory != null) {
					applicationDomain = factory.info().currentDomain as ApplicationDomain;
				}
			} catch (e:Error) {
			}
		}

		/**
		 *
		 */
		protected function instantiateSingletons():void {
			var names:Vector.<String> = _objectFactory.objectDefinitionRegistry.getSingletons();
			for each (var name:String in names) {
				if (!_objectFactory.cache.hasInstance(name)) {
					_objectFactory.getObject(name);
				}
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
		protected function propertyTextFilesLoadComplete(propertySources:Vector.<String>):void {
			var source:String = propertySources.join(NEWLINE_CHAR);
			propertiesParser ||= new KeyValuePropertiesParser();
			propertiesProvider ||= new Properties();
			propertiesParser.parseProperties(source, propertiesProvider);
		}

		/**
		 *
		 * @param event
		 */
		protected function providerCompleteHandler(event:OperationEvent):void {
			var result:AsyncObjectDefinitionProviderResult = AsyncObjectDefinitionProviderResult(event.result);
			handleObjectDefinitionResult(result.objectDefinitions, result.propertiesProvider, result.propertyURIs);
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
	}
}
