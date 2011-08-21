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
	import org.as3commons.eventbus.IEventBusListener;
	import org.as3commons.lang.Assert;
	import org.as3commons.lang.ClassNotFoundError;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.lang.util.OrderedUtils;
	import org.as3commons.reflect.Method;
	import org.as3commons.reflect.MethodInvoker;
	import org.as3commons.reflect.Type;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistryAware;
	import org.springextensions.actionscript.eventbus.impl.DefaultEventBusUserRegistry;
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
	import org.springextensions.actionscript.util.ContextUtils;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultObjectFactory extends EventDispatcher implements IObjectFactory, IEventBusAware, IAutowireProcessorAware, IDisposable, IEventBusUserRegistryAware {

		public static const OBJECT_FACTORY_PREFIX:String = "&";
		private static const NON_LAZY_SINGLETON_CTOR_ARGS_ERROR:String = "The object definition for '{0}' is not lazy. Constructor arguments can only be supplied for lazy instantiating objects.";
		private static const OBJECT_DEFINITION_NOT_FOUND_ERROR:String = "An object definition for '{0}' was not found.";

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
		private var _eventBusUserRegistry:IEventBusUserRegistry;
		private var _isDisposed:Boolean;
		private var _isReady:Boolean;
		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;
		private var _objectPostProcessors:Vector.<IObjectPostProcessor>;
		private var _parent:IObjectFactory;
		private var _properties:Properties;
		private var _propertiesProvider:IPropertiesProvider;
		private var _referenceResolvers:Vector.<IReferenceResolver>;

		/**
		 * @inheritDoc
		 */
		public function get applicationDomain():ApplicationDomain {
			return _applicationDomain;
		}

		/**
		 * @private
		 */
		public function set applicationDomain(value:ApplicationDomain):void {
			value ||= ApplicationDomain.currentDomain;
			_applicationDomain = value;
			var appDomainAware:IApplicationDomainAware = (_objectDefinitionRegistry as IApplicationDomainAware);
			if (appDomainAware != null) {
				appDomainAware.applicationDomain = this.applicationDomain;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get autowireProcessor():IAutowireProcessor {
			return _autowireProcessor;
		}

		/**
		 * @private
		 */
		public function set autowireProcessor(value:IAutowireProcessor):void {
			_autowireProcessor = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get cache():IInstanceCache {
			return _cache;
		}

		/**
		 * @private
		 */
		public function set cache(value:IInstanceCache):void {
			_cache = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get dependencyInjector():IDependencyInjector {
			return _dependencyInjector;
		}

		/**
		 * @private
		 */
		public function set dependencyInjector(value:IDependencyInjector):void {
			_dependencyInjector = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get eventBus():IEventBus {
			return _eventBus;
		}

		/**
		 * @private
		 */
		public function set eventBus(value:IEventBus):void {
			if (value !== _eventBus) {
				removeParentEventBusListener();
				ContextUtils.disposeInstance(_eventBusUserRegistry);
				_eventBus = value;
				addParentEventBusListener();
				if (_eventBus != null) {
					_eventBusUserRegistry = new DefaultEventBusUserRegistry();
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get eventBusUserRegistry():IEventBusUserRegistry {
			return _eventBusUserRegistry;
		}

		/**
		 * @private
		 */
		public function set eventBusUserRegistry(value:IEventBusUserRegistry):void {
			_eventBusUserRegistry = value;
		}

		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		/**
		 * @inheritDoc
		 */
		public function get isReady():Boolean {
			return _isReady;
		}

		/**
		 * @private
		 */
		public function set isReady(value:Boolean):void {
			_isReady = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectDefinitionRegistry;
		}

		/**
		 * @private
		 */
		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_objectDefinitionRegistry = value;
			var appDomainAware:IApplicationDomainAware = (_objectDefinitionRegistry as IApplicationDomainAware);
			if (appDomainAware != null) {
				appDomainAware.applicationDomain = this.applicationDomain;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get objectPostProcessors():Vector.<IObjectPostProcessor> {
			if (_objectPostProcessors == null) {
				_objectPostProcessors = new Vector.<IObjectPostProcessor>();
			}
			return _objectPostProcessors;
		}

		/**
		 * @inheritDoc
		 */
		public function get parent():IObjectFactory {
			return _parent;
		}

		/**
		 * @private
		 */
		public function set parent(value:IObjectFactory):void {
			if (_parent !== value) {
				removeParentEventBusListener();
				_parent = parent;
				addParentEventBusListener();
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get propertiesProvider():IPropertiesProvider {
			return _propertiesProvider;
		}

		/**
		 * @private
		 */
		public function set propertiesProvider(value:IPropertiesProvider):void {
			_propertiesProvider = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get referenceResolvers():Vector.<IReferenceResolver> {
			if (_referenceResolvers == null) {
				_referenceResolvers = new Vector.<IReferenceResolver>();
			}
			return _referenceResolvers;
		}

		/**
		 * @inheritDoc
		 */
		public function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):void {
			objectPostProcessors[objectPostProcessors.length] = objectPostProcessor;
			_objectPostProcessors.sort(OrderedUtils.orderedCompareFunction);
		}

		/**
		 * @inheritDoc
		 */
		public function addReferenceResolver(referenceResolver:IReferenceResolver):void {
			referenceResolvers[referenceResolvers.length] = referenceResolver;
			_referenceResolvers.sort(OrderedUtils.orderedCompareFunction);
		}

		/**
		 * @inheritDoc
		 */
		public function createInstance(clazz:Class, constructorArguments:Array=null):* {
			Assert.notNull(clazz, "The clazz arguments must not be null");
			var result:* = ClassUtils.newInstance(clazz, constructorArguments);
			if (dependencyInjector != null) {
				dependencyInjector.wire(result, this);
			}
			return result;
		}

		public function dispose():void {
			if (!_isDisposed) {
				_applicationDomain = null;
				ContextUtils.disposeInstance(_autowireProcessor);
				_autowireProcessor = null;
				ContextUtils.disposeInstance(_cache);
				_cache = null;
				ContextUtils.disposeInstance(_dependencyInjector);
				_dependencyInjector = null;
				_eventBus.clear();
				ContextUtils.disposeInstance(_eventBus);
				_eventBus = null;
				ContextUtils.disposeInstance(_objectDefinitionRegistry);
				_objectDefinitionRegistry = null;
				for each (var postProcessor:IObjectPostProcessor in _objectPostProcessors) {
					ContextUtils.disposeInstance(postProcessor);
				}
				_objectPostProcessors = null;
				_parent = null; //Do NOT invoke dispose() on the parent!
				ContextUtils.disposeInstance(_propertiesProvider);
				_propertiesProvider = null;
				for each (var resolver:IReferenceResolver in _referenceResolvers) {
					ContextUtils.disposeInstance(resolver);
				}
				_referenceResolvers = null;
				_isDisposed = true;
			}
		}


		/**
		 * @inheritDoc
		 */
		public function getObject(name:String, constructorArguments:Array=null):* {
			Assert.hasText(name, "name parameter must not be empty");
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

		/**
		 * @inheritDoc
		 */
		public function getObjectDefinition(objectName:String):IObjectDefinition {
			if (_objectDefinitionRegistry != null) {
				return _objectDefinitionRegistry.getObjectDefinition(objectName);
			}
			return null;
		}

		/**
		 * @inheritDoc
		 */
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
		 * @inheritDoc
		 */
		public function resolveReferences(properties:Array):Array {
			if ((!properties) || (properties.length == 0)) {
				return null;
			}
			var result:Array = [];
			for each (var prop:* in properties) {
				result[result.length] = resolveReference(prop);
			}
			return result;
		}

		protected function addParentEventBusListener():void {
			if ((parent is IEventBusAware) && (_eventBus is IEventBusListener)) {
				IEventBusAware(parent).eventBus.addListener(IEventBusListener(_eventBus));
			}
		}

		protected function attemptToInstantiate(objectDefinition:IObjectDefinition, constructorArguments:Array, name:String, objectName:String):* {
			var result:* = null;
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
			return result;
		}

		/**
		 * @inheritDoc
		 */
		protected function buildObject(name:String, constructorArguments:Array):* {
			var result:*;
			var isFactoryDereference:Boolean = (name.charAt(0) == OBJECT_FACTORY_PREFIX);
			var objectName:String = (isFactoryDereference ? name.substring(1) : name);
			var objectDefinition:IObjectDefinition = getObjectDefinition(objectName);

			if (!objectDefinition) {
				return getObjectFromParentFactory(name, constructorArguments);
			} else if (objectDefinition.isInterface) {
				throw new ObjectFactoryError(ObjectFactoryError.CANNOT_INSTANTIATE_INTERFACE, StringUtils.substitute("Objectdefinition {0} describes an interface which cannot be directly instantiated", objectName));
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
				result = attemptToInstantiate(objectDefinition, constructorArguments, name, objectName);
			}
			return result;
		}

		/**
		 *
		 * @param result
		 * @param objectName
		 * @param objectDefinition
		 */
		protected function checkDependencies(result:*, objectName:String, objectDefinition:IObjectDefinition):void {
			if ((!result) || (_cache.isPrepared(objectName))) {
				// guarantee creation of objects that the current object depends on
				var dependsOn:Vector.<String> = objectDefinition.dependsOn;

				if (dependsOn) {
					for each (var dependsOnObject:String in dependsOn) {
						getObject(dependsOnObject);
					}
				}
			}
		}

		/**
		 *
		 * @param objectName
		 * @param methodName
		 * @param args
		 * @return
		 */
		protected function createObjectViaInstanceFactoryMethod(objectName:String, methodName:String, args:Array=null):* {
			var factoryObject:Object = getObject(objectName);
			var factoryObjectMethodInvoker:MethodInvoker = new MethodInvoker();
			factoryObjectMethodInvoker.target = factoryObject;
			factoryObjectMethodInvoker.method = methodName;
			factoryObjectMethodInvoker.arguments = args;
			return factoryObjectMethodInvoker.invoke();
		}

		/**
		 *
		 * @param clazz
		 * @param applicationDomain
		 * @param factoryMethodName
		 * @param args
		 * @return
		 */
		protected function createObjectViaStaticFactoryMethod(clazz:Class, applicationDomain:ApplicationDomain, factoryMethodName:String, args:Array=null):* {
			var type:Type = Type.forClass(clazz, applicationDomain);
			var factoryMethod:Method = type.getMethod(factoryMethodName);
			return factoryMethod.invoke(clazz, args);
		}

		/**
		 *
		 * @param evt
		 */
		protected function dispatchEventThroughEventBus(evt:ObjectFactoryEvent):void {
			if (_eventBus != null) {
				_eventBus.dispatchEvent(evt);
			}
		}

		/**
		 *
		 * @param objectName
		 * @return
		 */
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

		/**
		 *
		 * @param objectName
		 * @param _parent
		 * @return
		 */
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

		/**
		 *
		 * @param objectName
		 * @param constructorArguments
		 * @return
		 */
		protected function getObjectFromParentFactory(objectName:String, constructorArguments:Array):* {
			if (_parent) {
				var objectDefinition:IObjectDefinition = getObjectDefinitionFromParent(objectName, _parent);
				if (objectDefinition && objectDefinition.isSingleton) {
					return _parent.getObject(objectName, constructorArguments);
				}
			}
			if (!objectDefinition) {
				throw new ObjectDefinitionNotFoundError(StringUtils.substitute(OBJECT_DEFINITION_NOT_FOUND_ERROR, objectName));
			}
		}

		/**
		 * Initializes the current <code>DefaultObjectFactory</code>.
		 * @param parent
		 */
		protected function initObjectFactory(parentFactory:IObjectFactory):void {
			parent = parentFactory;
		}

		/**
		 *
		 * @param objectDefinition
		 * @param constructorArguments
		 * @return
		 */
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


		protected function removeParentEventBusListener():void {
			if ((parent is IEventBusAware) && (_eventBus is IEventBusListener)) {
				IEventBusAware(parent).eventBus.removeListener(IEventBusListener(_eventBus));
			}
		}
	}
}
