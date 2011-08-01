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
package org.springextensions.actionscript.ioc.factory.impl {

	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;

	import org.as3commons.collections.LinkedList;
	import org.as3commons.eventbus.IEventBus;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.definition.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.postprocess.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.postprocess.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	public class ObjectFactory extends EventDispatcher implements IObjectFactory {

		private var _parent:IObjectFactory;
		private var _applicationDomain:ApplicationDomain;
		private var _propertyProviders:Vector.<IPropertiesProvider>;
		private var _isReady:Boolean;
		private var _objectPostProcessors:LinkedList;
		private var _objectFactoryPostProcessors:LinkedList;
		private var _cache:IInstanceCache;
		private var _eventBus:IEventBus;
		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;
		private var _dependencyInjector:IDependencyInjector;

		/**
		 * Creates a new <code>ObjectFactory</code> instance.
		 */
		public function ObjectFactory() {
			super();
			initObjectFactory();
		}

		protected function initObjectFactory():void {
			_cache = new DefaultInstanceCache();
		}

		public function get parent():IObjectFactory {
			return _parent;
		}

		public function set parent(value:IObjectFactory):void {
			_parent = value;
		}

		public function get applicationDomain():ApplicationDomain {
			return _applicationDomain;
		}

		public function getObject(name:String, constructorArguments:Array = null):* {
			return null;
		}

		public function createInstance(clazz:Class, constructorArguments:Array = null):* {
			return null;
		}

		public function get propertyProviders():Vector.<IPropertiesProvider> {
			return _propertyProviders;
		}

		public function get isReady():Boolean {
			return _isReady;
		}

		public function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):void {
			objectPostProcessors.add(objectPostProcessor);
		}

		public function addObjectFactoryPostProcessor(objectFactoryPostProcessor:IObjectFactoryPostProcessor):void {
			objectFactoryPostProcessors.add(objectFactoryPostProcessor);
		}

		public function get objectPostProcessors():LinkedList {
			if (_objectPostProcessors == null) {
				_objectPostProcessors = new LinkedList();
			}
			return _objectPostProcessors;
		}

		public function get objectFactoryPostProcessors():LinkedList {
			if (_objectFactoryPostProcessors == null) {
				_objectFactoryPostProcessors = new LinkedList();
			}
			return _objectFactoryPostProcessors;
		}

		public function get cache():IInstanceCache {
			return _cache;
		}

		public function get eventBus():IEventBus {
			return _eventBus;
		}

		public function set eventBus(value:IEventBus):void {
			_eventBus = value;
		}

		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}

		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectDefinitionRegistry;
		}

		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_objectDefinitionRegistry = value;
		}

		public function get dependencyInjector():IDependencyInjector {
			return _dependencyInjector;
		}

		public function set dependencyInjector(value:IDependencyInjector):void {
			_dependencyInjector = value;
		}
	}
}
