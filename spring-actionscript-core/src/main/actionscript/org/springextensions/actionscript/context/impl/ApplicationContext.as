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
	import org.as3commons.async.operation.impl.LoadURLOperation;
	import org.as3commons.eventbus.IEventBus;
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
	import org.springextensions.actionscript.ioc.spring_actionscript_internal;

	[Event(name="complete", type="flash.events.Event")]
	/**
	 *
	 * @author Roland Zwaga
	 */
	public class ApplicationContext extends EventDispatcher implements IApplicationContext, IDisposable {
		private static const APPLICATION_CONTEXT_PROPERTIES_LOADER_NAME:String = "applicationContextPropertiesLoader";
		private static const NEWLINE_CHAR:String = "\n";

		/**
		 * Creates a new <code>ApplicationContext</code> instance.
		 * @param parent
		 * @param objFactory
		 */
		public function ApplicationContext(parent:IApplicationContext=null, objFactory:IObjectFactory=null) {
			super();
			initApplicationContext(parent, objFactory);
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

		public function addDefinitionProvider(provider:IObjectDefinitionsProvider):void {
			definitionProviders[definitionProviders.length] = provider;
		}

		public function addObjectFactoryPostProcessor(objectFactoryPostProcessor:IObjectFactoryPostProcessor):void {
			_objectFactory.addObjectFactoryPostProcessor(objectFactoryPostProcessor);
		}

		public function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):void {
			_objectFactory.addObjectPostProcessor(objectPostProcessor);
		}

		public function addReferenceResolver(referenceResolver:IReferenceResolver):void {
			_objectFactory.addReferenceResolver(referenceResolver);
		}

		public function get applicationDomain():ApplicationDomain {
			return _objectFactory.applicationDomain;
		}

		public function set applicationDomain(value:ApplicationDomain):void {
			_objectFactory.applicationDomain = value;
		}

		public function get cache():IInstanceCache {
			return _objectFactory.cache;
		}

		public function createInstance(clazz:Class, constructorArguments:Array=null):* {
			return _objectFactory.createInstance(clazz, constructorArguments);
		}

		public function get definitionProviders():Vector.<IObjectDefinitionsProvider> {
			if (_definitionProviders == null) {
				_definitionProviders = new Vector.<IObjectDefinitionsProvider>();
			}
			return _definitionProviders;
		}

		public function get dependencyInjector():IDependencyInjector {
			return _objectFactory.dependencyInjector;
		}

		public function set dependencyInjector(value:IDependencyInjector):void {
			_objectFactory.dependencyInjector = value;
		}

		public function dispose():void {
			if (!_isDisposed) {
				try {
					_propertiesLoader = null;
					if (_objectFactory is IDisposable) {
						IDisposable(_objectFactory).dispose();
					}
					_definitionProviders = null;
					_eventBus.clear();
					if (_eventBus is IDisposable) {
						IDisposable(_eventBus).dispose();
					}
					_operationQueue = null;
					_rootView = null;
					_stageProcessorRegistry.clear();
					if (_stageProcessorRegistry is IDisposable) {
						IDisposable(_stageProcessorRegistry).dispose();
					}
				} finally {
					_isDisposed = true;
				}
			}
		}

		public function get eventBus():IEventBus {
			return _eventBus;
		}

		public function set eventBus(value:IEventBus):void {
			_eventBus = value;
		}

		public function getObject(name:String, constructorArguments:Array=null):* {
			return _objectFactory.getObject(name, constructorArguments);
		}

		public function getObjectDefinition(objectName:String):IObjectDefinition {
			return _objectFactory.getObjectDefinition(objectName);
		}

		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		public function get isReady():Boolean {
			return _objectFactory.isReady;
		}

		public function set isReady(value:Boolean):void {
			_objectFactory.isReady = true;
		}

		public function load():void {
			if (!isReady) {
				_operationQueue = new OperationQueue("definitionProviderQueue");
				for each (var provider:IObjectDefinitionsProvider in definitionProviders) {
					var operation:IOperation = provider.createDefinitions();
					if (operation != null) {
						operation.addCompleteListener(providerCompleteHandler);
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
					completeContextLoading();
				}
			}
		}

		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectFactory.objectDefinitionRegistry;
		}

		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_objectFactory.objectDefinitionRegistry = value;
		}

		public function get objectFactoryPostProcessors():Vector.<IObjectFactoryPostProcessor> {
			return _objectFactory.objectFactoryPostProcessors;
		}

		public function get objectPostProcessors():Vector.<IObjectPostProcessor> {
			return _objectFactory.objectPostProcessors;
		}

		public function get parent():IObjectFactory {
			return _objectFactory.parent;
		}

		public function set parent(value:IObjectFactory):void {
			_objectFactory.parent = value;
		}

		public function get propertiesParser():IPropertiesParser {
			return _propertiesParser;
		}

		public function set propertiesParser(value:IPropertiesParser):void {
			_propertiesParser = value;
		}

		public function get propertiesProvider():IPropertiesProvider {
			return _objectFactory.propertiesProvider;
		}

		public function set propertiesProvider(value:IPropertiesProvider):void {
			_objectFactory.propertiesProvider = value;
		}

		public function get referenceResolvers():Vector.<IReferenceResolver> {
			return _objectFactory.referenceResolvers;
		}

		public function resolveReference(property:*):* {
			return _objectFactory.resolveReference(property);
		}

		public function get rootView():DisplayObject {
			return _rootView;
		}

		public function get stageProcessorRegistry():IStageObjectProcessorRegistry {
			return _stageProcessorRegistry;
		}

		public function set stageProcessorRegistry(value:IStageObjectProcessorRegistry):void {
			_stageProcessorRegistry = value;
		}

		protected function cleanOperation(operation:IOperation):void {
			operation.removeCompleteListener(providerCompleteHandler);
		}

		protected function cleanQueue(_operationQueue:OperationQueue):void {
			_operationQueue.removeCompleteListener(providersLoadedHandler);
			_operationQueue.removeErrorListener(providersLoadErrorHandler);
		}

		protected function initApplicationContext(parent:IApplicationContext, objFactory:IObjectFactory):void {
			_objectFactory = objFactory ||= createDefaultObjectFactory(parent);
		}


		protected function loadPropertyURIs(propertyURIs:Vector.<PropertyURI>):void {
			if (_propertiesLoader == null) {
				_propertiesLoader = new PropertiesLoader(APPLICATION_CONTEXT_PROPERTIES_LOADER_NAME);
				_propertiesLoader.addCompleteListener(propertiesLoaderComplete, false, 0, true);
				_operationQueue.addOperation(_propertiesLoader);
			}
			_propertiesLoader.addURIs(propertyURIs);
		}

		protected function propertiesLoaderComplete(propertySources:Vector.<String>):void {
			var source:String = propertySources.join(NEWLINE_CHAR);
			propertiesParser ||= new KeyValuePropertiesParser();
			propertiesProvider = new Properties();
			propertiesParser.parseProperties(source, propertiesProvider);
		}

		protected function providerCompleteHandler(event:OperationEvent):void {
			cleanOperation(event.operation);
			var result:AsyncObjectDefinitionProviderResult = AsyncObjectDefinitionProviderResult(event.result);
			registerObjectDefinitions(result.objectDefinitions);
			if (result.propertyURIs != null) {
				loadPropertyURIs(result.propertyURIs);
			}
		}

		protected function providersLoadErrorHandler(error:*):void {
			cleanQueue(_operationQueue);
			throw new Error("Not implemented yet");
		}

		protected function providersLoadedHandler(operationEvent:OperationEvent):void {
			cleanQueue(_operationQueue);
			completeContextLoading();
		}

		protected function registerObjectDefinitions(newObjectDefinitions:Object):void {
			if (objectDefinitionRegistry != null) {
				for (var name:String in newObjectDefinitions) {
					objectDefinitionRegistry.registerObjectDefinition(name, newObjectDefinitions[name]);
				}
			}
		}

		private function completeContextLoading():void {
			if ((propertiesProvider != null) && (propertiesProvider.length > 0)) {
				//addObjectFactoryPostProcessor(
			}
			_objectFactory.isReady = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function createDefaultObjectFactory(parent:IApplicationContext):IObjectFactory {
			var defaultObjectFactory:DefaultObjectFactory = new DefaultObjectFactory(parent);
			defaultObjectFactory.eventBus = new EventBus();
			defaultObjectFactory.dependencyInjector = new DefaultDependencyInjector();
			var autowireProcessor:DefaultAutowireProcessor = new DefaultAutowireProcessor(this);
			defaultObjectFactory.autowireProcessor = autowireProcessor;
			return defaultObjectFactory;
		}
	}
}
