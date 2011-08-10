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

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;

	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.eventbus.IEventBusAware;
	import org.as3commons.lang.Assert;
	import org.as3commons.lang.ClassNotFoundError;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.lang.util.OrderedUtils;
	import org.as3commons.reflect.Method;
	import org.as3commons.reflect.MethodInvoker;
	import org.as3commons.reflect.Type;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessor;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessorAware;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.impl.Properties;
	import org.springextensions.actionscript.ioc.error.ObjectContainerError;
	import org.springextensions.actionscript.ioc.error.ObjectFactoryError;
	import org.springextensions.actionscript.ioc.factory.IFactoryObject;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.event.ObjectFactoryEvent;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.error.ObjectDefinitionNotFoundError;
	import org.springextensions.actionscript.ioc.spring_actionscript_internal;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultObjectFactory extends EventDispatcher implements IObjectFactory, IEventBusAware, IAutowireProcessorAware {

		public static const OBJECT_FACTORY_PREFIX:String = "&";
		private static const NON_LAZY_SINGLETON_CTOR_ARGS_ERROR:String = "The object definition for '{0}' is not lazy. Constructor arguments can only be supplied for lazy instantiating objects.";

		/**
		 * Creates a new <code>DefaultObjectFactory</code> instance.
		 * @param parent optional other <code>IObjectFactory</code> to be used as this <code>ObjectFactory's</code> parent.
		 *
		 */
		public function DefaultObjectFactory(parent:IObjectFactory=null) {
			super();
			initObjectFactory(parent);
		}

		private var _applicationDomain:ApplicationDomain;
		private var _autowireProcessor:IAutowireProcessor;
		private var _cache:IInstanceCache;
		private var _dependencyInjector:IDependencyInjector;
		private var _eventBus:IEventBus;
		private var _isReady:Boolean;
		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;
		private var _objectFactoryPostProcessors:Vector.<IObjectFactoryPostProcessor>;
		private var _objectPostProcessors:Vector.<IObjectPostProcessor>;
		private var _parent:IObjectFactory;
		private var _properties:Properties;
		private var _propertiesProvider:IPropertiesProvider;
		private var _referenceResolvers:Vector.<IReferenceResolver>;

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
			value ||= ApplicationDomain.currentDomain;
			_applicationDomain = value;
			var appDomainAware:IApplicationDomainAware = (_objectDefinitionRegistry as IApplicationDomainAware);
			if (appDomainAware != null) {
				appDomainAware.applicationDomain = this.applicationDomain;
			}
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

		public function set cache(value:IInstanceCache):void {
			_cache = value;
		}

		public function createInstance(clazz:Class, constructorArguments:Array=null):* {
			Assert.notNull(clazz, "The clazz arguments must not be null");
			if (!_isReady) {
				throw new ObjectFactoryError(ObjectFactoryError.FACTORY_NOT_READY, "Object factory isn't fully initialized yet");
			}
			var result:* = ClassUtils.newInstance(clazz, constructorArguments);
			if (dependencyInjector != null) {
				dependencyInjector.wire(result, this);
			}
			return result;
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

		public function getObject(name:String, constructorArguments:Array=null):* {
			Assert.hasText(name, "name parameter must not be empty");
			if (!_isReady) {
				throw new ObjectFactoryError(ObjectFactoryError.FACTORY_NOT_READY, "Object factory isn't fully initialized yet");
			}
			var result:*;
			var isFactoryDereference:Boolean = (name.charAt(0) == OBJECT_FACTORY_PREFIX);
			var objectName:String = (isFactoryDereference ? name.substring(1) : name);

			// try to get the object from the explicit singleton cache
			if (_cache.isPrepared(objectName)) {
				result = _cache.getPreparedInstance(objectName);
			} else {
				// we don't have an object in the cache, so create it
				result = buildObject(name, constructorArguments);
			}

			// if we have an object factory and we don't ask for the object factory,
			// replace the result with the object the factory creates
			if ((result is IFactoryObject) && !isFactoryDereference) {
				result = IFactoryObject(result).getObject();
			}

			var evt:ObjectFactoryEvent = new ObjectFactoryEvent(ObjectFactoryEvent.OBJECT_RETRIEVED, result, name, constructorArguments);
			dispatchEvent(evt);
			dispatchEventThroughEventBus(evt);
			return result;
		}

		public function get isReady():Boolean {
			return _isReady;
		}

		public function set isReady(value:Boolean):void {
			_isReady = value;
		}

		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectDefinitionRegistry;
		}

		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_objectDefinitionRegistry = value;
			var appDomainAware:IApplicationDomainAware = (_objectDefinitionRegistry as IApplicationDomainAware);
			if (appDomainAware != null) {
				appDomainAware.applicationDomain = this.applicationDomain;
			}
		}

		public function getObjectDefinition(objectName:String):IObjectDefinition {
			if (_objectDefinitionRegistry != null) {
				return _objectDefinitionRegistry.getObjectDefinition(objectName);
			}
			return null;
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

		public function get propertiesProvider():IPropertiesProvider {
			return _propertiesProvider;
		}

		public function set propertiesProvider(value:IPropertiesProvider):void {
			_propertiesProvider = value;
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

		public function resolveReferences(properties:Array):Array {
			if (properties.length == 0) {
				return null;
			}
			var result:Array = [];
			for each (var prop:* in properties) {
				result[result.length] = resolveReference(prop);
			}
			return result;
		}

		protected function buildObject(name:String, constructorArguments:Array):* {
			var result:*;
			var isFactoryDereference:Boolean = (name.charAt(0) == OBJECT_FACTORY_PREFIX);
			var objectName:String = (isFactoryDereference ? name.substring(1) : name);
			var objectDefinition:IObjectDefinition = getObjectDefinition(objectName);

			if (!objectDefinition) {
				return getObjectFromParentFactories(name, constructorArguments);
			}

			if (objectDefinition.isSingleton && (constructorArguments && !objectDefinition.isLazyInit)) {
				throw new IllegalOperationError(StringUtils.substitute(NON_LAZY_SINGLETON_CTOR_ARGS_ERROR, objectName));
			}

			if (objectDefinition.isSingleton) {
				result = getInstanceFromCache(objectName);
			}

			// Only do dependency guarantee loop when the object hasn't been retrieved from
			// the cache, when the object is in the early cache, do the dependency check. (Not sure if this is necessary though).
			checkDependencies(result, objectName, objectDefinition);

			// the object was not found in the cache or in the prepared cache
			// create a new object from its definition
			if (!result) {
				try {
					result = instantiateClass(objectDefinition, constructorArguments);
					var evt1:ObjectFactoryEvent = new ObjectFactoryEvent(ObjectFactoryEvent.OBJECT_CREATED, result, name, constructorArguments);
					dispatchEvent(evt1);
					dispatchEventThroughEventBus(evt1);
					if (dependencyInjector != null) {
						dependencyInjector.wire(result, this, objectDefinition, objectName);
						var evt2:ObjectFactoryEvent = new ObjectFactoryEvent(ObjectFactoryEvent.OBJECT_WIRED, result, name, constructorArguments);
						dispatchEvent(evt2);
						dispatchEventThroughEventBus(evt2);
					}
				} catch (e:ClassNotFoundError) {
					throw new ObjectContainerError(e.message, objectName);
				}
			}
			return result;
		}

		protected function checkDependencies(result:*, objectName:String, objectDefinition:IObjectDefinition):void {
			if ((!result) || (_cache.isPrepared(objectName))) {
				// guarantee creation of objects that the current object depends on
				var dependsOn:Array = objectDefinition.dependsOn;

				if (dependsOn) {
					for each (var dependsOnObject:String in dependsOn) {
						getObject(dependsOnObject);
					}
				}
			}
		}


		protected function createObjectViaInstanceFactoryMethod(objectName:String, methodName:String, args:Array=null):* {
			var factoryObject:Object = getObject(objectName);
			var factoryObjectMethodInvoker:MethodInvoker = new MethodInvoker();
			factoryObjectMethodInvoker.target = factoryObject;
			factoryObjectMethodInvoker.method = methodName;
			factoryObjectMethodInvoker.arguments = args;
			return factoryObjectMethodInvoker.invoke();
		}

		protected function createObjectViaStaticFactoryMethod(clazz:Class, applicationDomain:ApplicationDomain, factoryMethodName:String, args:Array=null):* {
			var type:Type = Type.forClass(clazz, applicationDomain);
			var factoryMethod:Method = type.getMethod(factoryMethodName);
			return factoryMethod.invoke(clazz, args);
		}

		protected function dispatchEventThroughEventBus(evt:ObjectFactoryEvent):void {
			if (_eventBus != null) {
				_eventBus.dispatchEvent(evt);
			}
		}


		protected function getInstanceFromCache(objectName:String):* {
			var result:*;
			if (_cache.hasInstance(objectName)) {
				result = _cache.getInstance(objectName);
			}

			// not in cache -> perhaps it is early cached as a circular reference
			if ((!result) && (_cache.isPrepared(objectName))) {
				result = _cache.getPreparedInstance(objectName);
			}
			return result;
		}

		protected function getObjectDefinitionFromParent(objectName:String, _parent:IObjectFactory):IObjectDefinition {
			var objectDefinition:IObjectDefinition = parent.getObjectDefinition(objectName);
			if (objectDefinition != null) {
				return objectDefinition;
			} else if (objectDefinition == null && parent.parent != null) {
				return getObjectDefinitionFromParent(objectName, parent.parent);
			} else {
				return null;
			}
		}

		protected function getObjectFromParentFactories(objectName:String, constructorArguments:Array):* {
			if (_parent) {
				var objectDefinition:IObjectDefinition = getObjectDefinitionFromParent(objectName, _parent);
				if (objectDefinition && objectDefinition.isSingleton) {
					return _parent.getObject(objectName, constructorArguments);
				}
			}
			if (!objectDefinition) {
				throw new ObjectDefinitionNotFoundError("An object definition for '" + objectName + "' was not found.");
			}
		}

		/**
		 * Initializes the current <code>DefaultObjectFactory</code>.
		 * @param parent
		 */
		protected function initObjectFactory(parent:IObjectFactory):void {
			if (parent !== _parent) {
				_parent = parent;
			}
		}

		protected function instantiateClass(objectDefinition:IObjectDefinition, constructorArguments:Array):* {
			var clazz:Class = ClassUtils.forName(objectDefinition.className, _applicationDomain);

			if (constructorArguments) {
				objectDefinition.constructorArguments = constructorArguments;
			}

			if (_autowireProcessor) {
				_autowireProcessor.preprocessObjectDefinition(objectDefinition);
			}

			// create the object
			var resolvedConstructorArgs:Array = resolveReferences(objectDefinition.constructorArguments);

			if (objectDefinition.factoryMethod) {
				if (objectDefinition.factoryObjectName) {
					return createObjectViaInstanceFactoryMethod(objectDefinition.factoryObjectName, objectDefinition.factoryMethod, resolvedConstructorArgs);
				} else {
					return createObjectViaStaticFactoryMethod(clazz, applicationDomain, objectDefinition.factoryMethod, resolvedConstructorArgs);
				}
			} else {
				return ClassUtils.newInstance(clazz, resolvedConstructorArgs);
			}
		}
	}
}
