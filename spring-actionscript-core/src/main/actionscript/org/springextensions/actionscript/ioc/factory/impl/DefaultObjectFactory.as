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

	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.eventbus.IEventBusAware;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.util.OrderedUtils;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessor;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessorAware;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultObjectFactory extends EventDispatcher implements IObjectFactory, IEventBusAware, IAutowireProcessorAware {

		public static const OBJECT_FACTORY_PREFIX:String = "&";

		/**
		 * Creates a new <code>DefaultObjectFactory</code> instance.
		 * @param parent optional other <code>IObjectFactory</code> to be used as this <code>ObjectFactory's</code> parent.
		 *
		 */
		public function DefaultObjectFactory(parent:IObjectFactory = null) {
			super();
			initObjectFactory(parent);
		}

		private var _applicationDomain:ApplicationDomain;
		private var _cache:IInstanceCache;
		private var _dependencyInjector:IDependencyInjector;
		private var _eventBus:IEventBus;
		private var _isReady:Boolean;
		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;
		private var _objectDefinitions:Object;
		private var _objectFactoryPostProcessors:Vector.<IObjectFactoryPostProcessor>;
		private var _objectPostProcessors:Vector.<IObjectPostProcessor>;
		private var _parent:IObjectFactory;
		private var _propertyProviders:Vector.<IPropertiesProvider>;
		private var _referenceResolvers:Vector.<IReferenceResolver>;
		private var _autowireProcessor:IAutowireProcessor;

		public function addObjectFactoryPostProcessor(objectFactoryPostProcessor:IObjectFactoryPostProcessor):void {
			objectFactoryPostProcessors[objectFactoryPostProcessors.length] = objectFactoryPostProcessor;
			_objectFactoryPostProcessors.sort(OrderedUtils.orderedCompareFunction);
		}

		public function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):void {
			objectPostProcessors[objectPostProcessors.length] = objectPostProcessor;
			_objectPostProcessors.sort(OrderedUtils.orderedCompareFunction);
		}

		public function addReferenceResolver(referenceResolver:IReferenceResolver):void {
			referenceResolvers[referenceResolvers.length] = referenceResolver;
			_referenceResolvers.sort(OrderedUtils.orderedCompareFunction);
		}

		public function get applicationDomain():ApplicationDomain {
			return _applicationDomain;
		}

		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}

		public function get autowireProcessor():IAutowireProcessor {
			return _autowireProcessor;
		}

		public function set autowireProcessor(value:IAutowireProcessor):void {
			_autowireProcessor = value;
		}

		public function get cache():IInstanceCache {
			return _cache;
		}

		public function createInstance(clazz:Class, constructorArguments:Array = null):* {
			return null;
		}

		public function get dependencyInjector():IDependencyInjector {
			return _dependencyInjector;
		}

		public function set dependencyInjector(value:IDependencyInjector):void {
			_dependencyInjector = value;
		}

		public function get eventBus():IEventBus {
			return _eventBus;
		}

		public function set eventBus(value:IEventBus):void {
			_eventBus = value;
		}

		public function getObject(name:String, constructorArguments:Array = null):* {
			throw new Error("Not implemented yet");
		}

		public function get isReady():Boolean {
			return _isReady;
		}

		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectDefinitionRegistry;
		}

		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_objectDefinitionRegistry = value;
		}

		public function get objectDefinitions():Object {
			return _objectDefinitions;
		}

		public function get objectFactoryPostProcessors():Vector.<IObjectFactoryPostProcessor> {
			if (_objectFactoryPostProcessors == null) {
				_objectFactoryPostProcessors = new Vector.<IObjectFactoryPostProcessor>();
			}
			return _objectFactoryPostProcessors;
		}

		public function get objectPostProcessors():Vector.<IObjectPostProcessor> {
			if (_objectPostProcessors == null) {
				_objectPostProcessors = new Vector.<IObjectPostProcessor>();
			}
			return _objectPostProcessors;
		}

		public function get parent():IObjectFactory {
			return _parent;
		}

		public function set parent(value:IObjectFactory):void {
			_parent = value;
		}

		public function get propertyProviders():Vector.<IPropertiesProvider> {
			return _propertyProviders;
		}

		public function get referenceResolvers():Vector.<IReferenceResolver> {
			if (_referenceResolvers == null) {
				_referenceResolvers = new Vector.<IReferenceResolver>();
			}
			return _referenceResolvers;
		}

		public function resolveReference(property:*):* {
			if (property == null) { // note: don't change this to !property since we might pass in empty strings here
				return null;
			}
			for each (var referenceResolver:IReferenceResolver in referenceResolvers) {
				if (referenceResolver.canResolve(property)) {
					return referenceResolver.resolve(property);
				}
			}
			return property;
		}

		/**
		 * Initializes the current <code>DefaultObjectFactory</code>.
		 * @param parent
		 */
		protected function initObjectFactory(parent:IObjectFactory):void {
			_objectDefinitions = {};
			if (parent !== _parent) {
				_parent = parent;
			}
		}
	}
}
