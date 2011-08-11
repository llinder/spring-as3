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
	import org.as3commons.async.operation.OperationEvent;
	import org.as3commons.async.operation.OperationQueue;
	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.eventbus.IEventBusAware;
	import org.as3commons.eventbus.impl.EventBus;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.stageprocessing.IStageObjectProcessorRegistry;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.impl.AsyncObjectDefinitionProviderResult;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesLoader;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesParser;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.PropertyURI;
	import org.springextensions.actionscript.ioc.config.property.impl.KeyValuePropertiesParser;
	import org.springextensions.actionscript.ioc.config.property.impl.Properties;
	import org.springextensions.actionscript.ioc.config.property.impl.PropertiesLoader;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
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
		private static const APPLICATION_CONTEXT_PROPERTIES_LOADER_NAME:String = "applicationContextPropertiesLoader";
		private static const DEFINITION_PROVIDER_QUEUE_NAME:String = "definitionProviderQueue";
		private static const NEWLINE_CHAR:String = "\n";
		private static const OBJECT_FACTORY_POST_PROCESSOR_QUEUE_NAME:String = "objectFactoryPostProcessorQueue";

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
		private var _operationQueue:OperationQueue;
		private var _propertiesLoader:IPropertiesLoader;
		private var _propertiesParser:IPropertiesParser;
		private var _rootView:DisplayObject;
		private var _stageProcessorRegistry:IStageObjectProcessorRegistry;

		/**
		 * @inheritDoc
		 */
		public function addDefinitionProvider(provider:IObjectDefinitionsProvider):void {
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
		public function createInstance(clazz:Class, constructorArguments:Array=null):* {
			return _objectFactory.createInstance(clazz, constructorArguments);
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
		 * Clears, disposes and nulls out every member of the current <code>ApplicationContext</code>.
		 */
		public function dispose():void {
			if (!_isDisposed) {
				try {
					ContextUtils.disposeInstance(_propertiesLoader);
					_propertiesLoader = null;

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

		public function load():void {
			if (!isReady) {
				_operationQueue = new OperationQueue(DEFINITION_PROVIDER_QUEUE_NAME);
				for each (var provider:IObjectDefinitionsProvider in definitionProviders) {
					var operation:IOperation = provider.createDefinitions();
					if (operation != null) {
						operation.addCompleteListener(providerCompleteHandler, false, 0, true);
						_operationQueue.addOperation(operation);
					} else {
						registerObjectDefinitions(provider.objectDefinitions);
						if (provider.propertyURIs != null) {
							loadPropertyURIs(provider.propertyURIs);
						}
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
		public function get propertiesLoader():IPropertiesLoader {
			return _propertiesLoader;
		}

		/**
		 * @private
		 */
		public function set propertiesLoader(value:IPropertiesLoader):void {
			_propertiesLoader = value;
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
		 * @private
		 */
		public function resolveReference(property:*):* {
			return _objectFactory.resolveReference(property);
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
		 *
		 * @param _operationQueue
		 */
		protected function cleanQueueAfterDefinitionProviders(_operationQueue:OperationQueue):void {
			_operationQueue.removeCompleteListener(providersLoadedHandler);
			_operationQueue.removeErrorListener(providersLoadErrorHandler);
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
			ContextUtils.disposeInstance(_propertiesLoader);
			_propertiesLoader = null;
			_objectFactory.isReady = true;
			instantiateSingletons();
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
		protected function createPropertiesLoader():IPropertiesLoader {
			var propertiesLoader:IPropertiesLoader = new PropertiesLoader(APPLICATION_CONTEXT_PROPERTIES_LOADER_NAME);
			propertiesLoader.addCompleteListener(propertiesLoaderComplete, false, 0, true);
			_operationQueue.addOperation(propertiesLoader);
			return propertiesLoader;
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
		protected function loadPropertyURIs(propertyURIs:Vector.<PropertyURI>):void {
			_propertiesLoader ||= createPropertiesLoader();
			_propertiesLoader.addURIs(propertyURIs);
		}

		/**
		 *
		 * @param propertySources
		 */
		protected function propertiesLoaderComplete(propertySources:Vector.<String>):void {
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
			registerObjectDefinitions(result.objectDefinitions);
			if (result.propertyURIs != null) {
				loadPropertyURIs(result.propertyURIs);
			}
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
