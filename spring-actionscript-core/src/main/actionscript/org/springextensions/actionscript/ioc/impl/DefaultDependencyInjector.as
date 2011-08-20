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
package org.springextensions.actionscript.ioc.impl {
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;

	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.reflect.Field;
	import org.as3commons.reflect.MethodInvoker;
	import org.as3commons.reflect.Type;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessorAware;
	import org.springextensions.actionscript.ioc.error.ResolveReferenceError;
	import org.springextensions.actionscript.ioc.error.UnsatisfiedDependencyError;
	import org.springextensions.actionscript.ioc.factory.IInitializingObject;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;
	import org.springextensions.actionscript.object.ITypeConverter;
	import org.springextensions.actionscript.object.SimpleTypeConverter;
	import org.springextensions.actionscript.util.TypeUtils;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultDependencyInjector extends EventDispatcher implements IDependencyInjector, IApplicationDomainAware {

		private static const DEFAULT_OBJECTNAME:String = "(no name)";
		private static const ID_FIELD_NAME:String = "id";
		private static const PROTOTYPE_FIELD_NAME:String = 'prototype';

		/**
		 * Creates a new <code>DefaultDependencyInjector</code> instance.
		 */
		public function DefaultDependencyInjector() {
			super();
		}

		private var _applicationDomain:ApplicationDomain;
		private var _typeConverter:ITypeConverter;

		/**
		 * @inheritDoc
		 */
		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
			if (_typeConverter != null) {
				_typeConverter = new SimpleTypeConverter(_applicationDomain);
			}
		}

		/**
		 *
		 */
		public function get typeConverter():ITypeConverter {
			if (_typeConverter == null) {
				_typeConverter = new SimpleTypeConverter(_applicationDomain);
			}
			return _typeConverter;
		}

		/**
		 * @private
		 */
		public function set typeConverter(value:ITypeConverter):void {
			_typeConverter = value;
		}

		/**
		 * @inheritDoc
		 */
		public function wire(instance:*, objectFactory:IObjectFactory, objectDefinition:IObjectDefinition=null, objectName:String=null):void {
			if (objectDefinition == null) {
				wireWithoutObjectDefinition(instance, objectName, objectFactory);
			} else {
				wireWithObjectDefinition(instance, objectFactory, objectName, objectDefinition);
			}
		}

		/**
		 *
		 * @param instance
		 * @param objectName
		 * @param objectFactory
		 * @param objectDefinition
		 */
		protected function autowireInstance(instance:*, objectName:String, objectFactory:IObjectFactory, objectDefinition:IObjectDefinition=null):void {
			var autoWireAware:IAutowireProcessorAware = objectFactory as IAutowireProcessorAware;
			if ((autoWireAware != null) && (autoWireAware.autowireProcessor != null)) {
				autoWireAware.autowireProcessor.autoWire(instance, objectDefinition, objectName);
			}
		}


		/**
		 * Caches the object if its definition is a singleton<br/>
		 * Note: if the object is an <code>IFactoryObject</code>, the <code>IFactoryObject</code> instance is cached and not the
		 * object it creates
		 * @param objectDefinition
		 * @param cache
		 * @param objectName
		 * @param instance
		 */
		protected function cacheSingleton(objectDefinition:IObjectDefinition, cache:IInstanceCache, objectName:String, instance:*):void {
			if (objectDefinition.isSingleton) {
				cache.addInstance(objectName, instance);
			}
		}

		/**
		 *
		 * @param objectDefinition
		 * @param instance
		 * @param objectName
		 */
		protected function checkDependencies(objectDefinition:IObjectDefinition, instance:*, objectName:String):void {
			if (objectDefinition.dependencyCheck !== DependencyCheckMode.NONE) {
				performDependencyCheck(instance, objectDefinition, objectName);
			}
		}


		/**
		 *
		 * @param objectDefinition
		 * @param instance
		 * @param objectFactory
		 */
		protected function executeMethodInvocations(objectDefinition:IObjectDefinition, instance:*, objectFactory:IObjectFactory):void {
			if (objectDefinition.methodInvocations) {
				for each (var methodInvocation:MethodInvocation in objectDefinition.methodInvocations) {
					var methodInvoker:MethodInvoker = new MethodInvoker();
					methodInvoker.target = instance;
					methodInvoker.method = methodInvocation.methodName;
					methodInvoker.namespaceURI = methodInvocation.namespaceURI;
					methodInvoker.arguments = resolveReferences(methodInvocation.arguments, objectFactory);
					methodInvoker.invoke();
				}
			}
		}

		/**
		 *
		 * @param instance
		 * @param objectDefinition
		 */
		protected function initializeInstance(instance:*, objectDefinition:IObjectDefinition=null):void {
			if (instance is IInitializingObject) {
				IInitializingObject(instance).afterPropertiesSet();
			}

			if ((objectDefinition != null) && (StringUtils.hasText(objectDefinition.initMethod))) {
				instance[objectDefinition.initMethod]();
			}
		}

		/**
		 *
		 * @param instance
		 * @param objectDefinition
		 * @param name
		 */
		protected function performDependencyCheck(instance:*, objectDefinition:IObjectDefinition, name:String):void {
			var type:Type = Type.forInstance(instance, _applicationDomain);
			for each (var field:Field in type.properties) {
				if (field.name == PROTOTYPE_FIELD_NAME) {
					continue;
				}
				var isSimple:Boolean = TypeUtils.isSimpleProperty(field.type);
				var isNull:Boolean = (field.getValue(instance) == null);
				var unSatisfied:Boolean = (isNull && //
					(isSimple && objectDefinition.dependencyCheck.checkSimpleProperties() || //
					(!isSimple && objectDefinition.dependencyCheck.checkObjectProperties())) //
					);
				if (unSatisfied) {
					throw new UnsatisfiedDependencyError(name, field.name);
				}
			}
		}

		/**
		 *
		 * @param instance
		 * @param objectName
		 * @param objectPostProcessors
		 */
		protected function postProcessingAfterInitialization(instance:*, objectName:String, objectPostProcessors:Vector.<IObjectPostProcessor>):void {
			for each (var processor:IObjectPostProcessor in objectPostProcessors) {
				processor.postProcessAfterInitialization(instance, objectName);
			}
		}

		/**
		 *
		 * @param instance
		 * @param objectName
		 * @param objectPostProcessors
		 */
		protected function postProcessingBeforeInitialization(instance:*, objectName:String, objectPostProcessors:Vector.<IObjectPostProcessor>):void {
			for each (var processor:IObjectPostProcessor in objectPostProcessors) {
				processor.postProcessBeforeInitialization(instance, objectName);
			}
		}

		/**
		 *
		 * @param objectDefinition
		 * @param cache
		 * @param instance
		 * @param objectName
		 */
		protected function prepareSingleton(objectDefinition:IObjectDefinition, cache:IInstanceCache, instance:*, objectName:String):void {
			if (objectDefinition.isSingleton) {
				cache.prepareInstance(objectName, instance);
			}
		}

		protected function resolveObjectName(objectName:String, instance:*):String {
			if (!StringUtils.hasText(objectName)) {
				if (instance.hasOwnProperty(ID_FIELD_NAME)) {
					objectName = instance[ID_FIELD_NAME];
				} else {
					objectName = DEFAULT_OBJECTNAME;
				}
			}
			return objectName;
		}

		/**
		 *
		 * @param properties
		 * @param objectFactory
		 * @return
		 */
		protected function resolveReferences(properties:Array, objectFactory:IObjectFactory):Array {
			var result:Array = [];
			for each (var p:Object in properties) {
				result[result.length] = objectFactory.resolveReference(p);
			}
			return result;
		}

		/**
		 * Set the properties on the newly created object as defined by the specified <code>IObjectDefinition</code>.
		 * @param instance The newly created object
		 * @param objectDefinition The specified <code>IObjectDefinition</code>
		 * @param objectName The name of the newly created object as known by the object factory
		 * @param referenceResolvers A collection of <code>IReferenceResolver</code> used to resolve the property values as defined by the specified <code>IObjectDefinition</code>.
		 */
		protected function setPropertiesFromObjectDefinition(instance:*, objectDefinition:IObjectDefinition, objectName:String, objectFactory:IObjectFactory):void {
			var newValue:*;
			var clazz:Class;
			var target:Object;
			for each (var property:PropertyDefinition in objectDefinition.properties) {
				clazz ||= ClassUtils.forInstance(instance, _applicationDomain);
				// Note: Using two try blocks in order to improve error reporting
				// resolve the reference to the property
				try {
					newValue = objectFactory.resolveReference(property.value);
				} catch (e:Error) {
					throw new ResolveReferenceError(StringUtils.substitute("The property '{0}' on the definition of '{1}' could not be resolved. Original error: {2}\n", property, objectName, e.message));
				}

				try {
					var type:Type = Type.forClass(clazz, _applicationDomain);
					var field:Field = type.getField(property.name);

					if (newValue && field && field.type.clazz) {
						newValue = typeConverter.convertIfNecessary(newValue, field.type.clazz);
					}

					if (!property.isStatic) {
						target = instance;
					} else {
						target = clazz;
					}

					if (!StringUtils.hasText(property.namespaceURI)) {
						target[property.name] = newValue;
					} else {
						target[property.qName] = newValue;
					}
				} catch (e:Error) {
					throw e;
				}
			}
		}

		/**
		 *
		 * @param instance
		 * @param objectFactory
		 * @param objectName
		 * @param objectDefinition
		 */
		protected function wireWithObjectDefinition(instance:*, objectFactory:IObjectFactory, objectName:String, objectDefinition:IObjectDefinition):void {
			objectName ||= objectDefinition.className;

			prepareSingleton(objectDefinition, objectFactory.cache, instance, objectName);

			// Autowire happens before setting all explicitly configured properties
			// so that autowired properties can be overridden.
			autowireInstance(instance, objectName, objectFactory, objectDefinition);

			setPropertiesFromObjectDefinition(instance, objectDefinition, objectName, objectFactory);

			if (!objectDefinition.skipPostProcessors) {
				postProcessingBeforeInitialization(instance, objectName, objectFactory.objectPostProcessors);
			}

			checkDependencies(objectDefinition, instance, objectName);

			initializeInstance(instance, objectDefinition);

			executeMethodInvocations(objectDefinition, instance, objectFactory);

			if (!objectDefinition.skipPostProcessors) {
				postProcessingAfterInitialization(instance, objectName, objectFactory.objectPostProcessors);
			}

			executeCustomConfiguration(instance, objectDefinition);

			cacheSingleton(objectDefinition, objectFactory.cache, objectName, instance);
		}

		/**
		 *
		 * @param instance
		 * @param objectDefinition
		 */
		protected function executeCustomConfiguration(instance:*, objectDefinition:IObjectDefinition):void {
			if (objectDefinition.customConfiguration is ICustomConfigurator) {
				ICustomConfigurator(objectDefinition.customConfiguration).execute(instance, objectDefinition);
			} else if (objectDefinition.customConfiguration is Vector.<ICustomConfigurator>) {
				var configurators:Vector.<ICustomConfigurator> = objectDefinition.customConfiguration as Vector.<ICustomConfigurator>;
				for each (var configurator:ICustomConfigurator in configurators) {
					configurator.execute(instance, objectDefinition);
				}
			}
		}

		/**
		 *
		 * @param instance
		 * @param objectName
		 * @param objectFactory
		 */
		protected function wireWithoutObjectDefinition(instance:*, objectName:String, objectFactory:IObjectFactory):void {
			objectName = resolveObjectName(objectName, instance);

			autowireInstance(instance, objectName, objectFactory);

			var processors:Vector.<IObjectPostProcessor> = objectFactory.objectPostProcessors;

			postProcessingBeforeInitialization(instance, objectName, processors);

			initializeInstance(instance);

			postProcessingAfterInitialization(instance, objectName, processors);
		}
	}
}
