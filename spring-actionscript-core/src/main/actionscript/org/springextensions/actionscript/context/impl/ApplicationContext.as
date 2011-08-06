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
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;

	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.stageprocessing.IStageObjectProcessorRegistry;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.impl.Properties;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.impl.DefaultDependencyInjector;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 *
	 */
	public class ApplicationContext extends EventDispatcher implements IApplicationContext {

		public function ApplicationContext(parent:IApplicationContext = null, objFactory:IObjectFactory = null) {
			super();
			initApplicationContext(parent, objFactory);
		}

		private var _definitionProviders:Vector.<IObjectDefinitionsProvider>;
		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;
		private var _objectFactory:IObjectFactory;
		private var _stageProcessorRegistry:IStageObjectProcessorRegistry;
		private var _rootView:DisplayObject;
		private var _eventBus:IEventBus;
		private var _definitionRegistry:IObjectDefinitionRegistry;

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

		public function createInstance(clazz:Class, constructorArguments:Array = null):* {
			return _objectFactory.createInstance(clazz, constructorArguments);
		}

		public function get definitionProviders():Vector.<IObjectDefinitionsProvider> {
			if (_definitionProviders == null) {
				_definitionProviders = Vector.<IObjectDefinitionsProvider>();
			}
			return _definitionProviders;
		}

		public function get definitionRegistry():IObjectDefinitionRegistry {
			return _definitionRegistry;
		}

		public function set definitionRegistry(value:IObjectDefinitionRegistry):void {
			_definitionRegistry = value;
		}

		public function get dependencyInjector():IDependencyInjector {
			return _objectFactory.dependencyInjector;
		}

		public function set dependencyInjector(value:IDependencyInjector):void {
			_objectFactory.dependencyInjector = value;
		}

		public function get eventBus():IEventBus {
			return _eventBus;
		}

		public function set eventBus(value:IEventBus):void {
			_eventBus = value;
		}

		public function getObject(name:String, constructorArguments:Array = null):* {
			return _objectFactory.getObject(name, constructorArguments);
		}

		public function get isReady():Boolean {
			return _objectFactory.isReady;
		}

		public function load():void {
			throw new Error("Not implemented yet");
		}

		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectDefinitionRegistry;
		}

		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_objectDefinitionRegistry = value;
		}

		public function get objectDefinitions():Object {
			return _objectFactory.objectDefinitions;
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

		protected function initApplicationContext(parent:IApplicationContext, objFactory:IObjectFactory):void {
			if (objFactory == null) {
				_objectFactory = new DefaultObjectFactory(parent);
				_objectFactory.dependencyInjector = new DefaultDependencyInjector();
				var autowireProcessor:DefaultAutowireProcessor = new DefaultAutowireProcessor(this);
				DefaultObjectFactory(_objectFactory).autowireProcessor = autowireProcessor;
			} else {
				_objectFactory = objFactory;
			}
		}

		public function get propertiesProvider():IPropertiesProvider {
			return _objectFactory.propertiesProvider;
		}

		public function set propertiesProvider(value:IPropertiesProvider):void {
			_objectFactory.propertiesProvider = value;
		}

	}
}
