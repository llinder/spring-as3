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
	import org.springextensions.actionscript.ioc.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.MethodInvocation;
	import org.springextensions.actionscript.ioc.ResolveReferenceError;
	import org.springextensions.actionscript.ioc.UnsatisfiedDependencyError;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessor;
	import org.springextensions.actionscript.ioc.factory.IInitializingObject;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
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
		private var _autowireProcessor:IAutowireProcessor;
		private var _typeConverter:ITypeConverter;

		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
			if (_typeConverter != null) {
				_typeConverter = new SimpleTypeConverter(_applicationDomain);
			}
		}

		public function get autowireProcessor():IAutowireProcessor {
			return _autowireProcessor;
		}

		public function set autowireProcessor(value:IAutowireProcessor):void {
			_autowireProcessor = value;
		}

		public function get typeConverter():ITypeConverter {
			if (_typeConverter == null) {
				_typeConverter = new SimpleTypeConverter(_applicationDomain);
			}
			return _typeConverter;
		}

		public function set typeConverter(value:ITypeConverter):void {
			_typeConverter = value;
		}

		/**
		 * @inheritDoc
		 */
		public function wire(instance:*, cache:IInstanceCache, objectDefinition:IObjectDefinition = null, objectName:String = null, objectPostProcessors:Vector.<IObjectPostProcessor> = null, referenceResolvers:Vector.<IReferenceResolver> = null):void {
			if (objectDefinition == null) {
				wireWithoutObjectDefinition(instance, objectName, objectPostProcessors);
			} else {
				wireWithObjectDefinition(objectName, objectDefinition, cache, instance, referenceResolvers, objectPostProcessors);
			}
		}


		protected function autowireInstance(instance:*, objectName:String, objectDefinition:IObjectDefinition = null):void {
			if (_autowireProcessor) {
				_autowireProcessor.autoWire(instance, objectDefinition, objectName);
			}
		}


		protected function cacheSingleton(objectDefinition:IObjectDefinition, cache:IInstanceCache, objectName:String, instance:*):void {
			if (objectDefinition.isSingleton) {
				// cache the object if its definition is a singleton
				// note: if the object is an object factory, the object factory is cached and not the
				// object it creates
				cache.addInstance(objectName, instance);
			}
		}


		protected function checkDependencies(objectDefinition:IObjectDefinition, instance:*, objectName:String):void {
			if (objectDefinition.dependencyCheck !== DependencyCheckMode.NONE) {
				performDependencyCheck(instance, objectDefinition, objectName);
			}
		}


		protected function executeMethodInvocations(objectDefinition:IObjectDefinition, instance:*, referenceResolvers:Vector.<IReferenceResolver>):void {
			// execute all method invocations if any
			if (objectDefinition.methodInvocations) {
				for each (var methodInvocation:MethodInvocation in objectDefinition.methodInvocations) {
					var methodInvoker:MethodInvoker = new MethodInvoker();
					methodInvoker.target = instance;
					methodInvoker.method = methodInvocation.methodName;
					methodInvoker.arguments = resolveReferences(methodInvocation.arguments, referenceResolvers);
					methodInvoker.invoke();
				}
			}
		}

		protected function initializeInstance(instance:*, objectDefinition:IObjectDefinition):void {
			if (instance is IInitializingObject) {
				IInitializingObject(instance).afterPropertiesSet();
			}

			if (objectDefinition.initMethod) {
				instance[objectDefinition.initMethod]();
			}
		}

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

		protected function postProcessingAfterInitialization(instance:*, objectName:String, objectPostProcessors:Vector.<IObjectPostProcessor>):void {
			for each (var processor:IObjectPostProcessor in objectPostProcessors) {
				processor.postProcessAfterInitialization(instance, objectName);
			}
		}

		protected function postProcessingBeforeInitialization(instance:*, objectName:String, objectPostProcessors:Vector.<IObjectPostProcessor>):void {
			for each (var processor:IObjectPostProcessor in objectPostProcessors) {
				processor.postProcessBeforeInitialization(instance, objectName);
			}
		}

		protected function prepareSingleton(objectDefinition:IObjectDefinition, cache:IInstanceCache, instance:*, objectName:String):void {
			if (objectDefinition.isSingleton) {
				cache.prepareInstance(instance, objectName);
			}
		}

		protected function resolveReference(property:*, referenceResolvers:Vector.<IReferenceResolver>):* {
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

		protected function resolveReferences(properties:Array, referenceResolvers:Vector.<IReferenceResolver>):Array {
			var result:Array = [];

			for each (var p:Object in properties) {
				result[result.length] = resolveReference(p, referenceResolvers);
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
		protected function setPropertiesFromObjectDefinition(instance:*, objectDefinition:IObjectDefinition, objectName:String, referenceResolvers:Vector.<IReferenceResolver>):void {
			var newValue:*;
			var clazz:Class;
			for (var property:String in objectDefinition.properties) {
				clazz ||= ClassUtils.forInstance(instance, _applicationDomain);
				// Note: Using two try blocks in order to improve error reporting
				// resolve the reference to the property
				try {
					newValue = resolveReference(objectDefinition.properties[property], referenceResolvers);
				} catch (e:Error) {
					throw new ResolveReferenceError(StringUtils.substitute("The property '{0}' on the definition of '{1}' could not be resolved. Original error: {2}\n", property, objectName, e.message));
				}

				// set the property on the created instance
				try {
					var type:Type = Type.forClass(clazz, _applicationDomain);
					var field:Field = type.getField(property);

					if (newValue && field && field.type.clazz) {
						newValue = typeConverter.convertIfNecessary(newValue, field.type.clazz);
					}

					// do the actual property setting
					// note: skip this if the current property is equal to the new property
					//if (object[property] !== newValue) {
					instance[property] = newValue;
						//}
						//} catch (typeError:TypeError) {
						//	throw new PropertyTypeError("The property '" + property + "' on the object definition '" + name + "' was given the wrong type. Original error: \n" + typeError.message);
				} catch (e:Error) {
					throw e;
				}
			}
		}

		protected function wireWithObjectDefinition(objectName:String, objectDefinition:IObjectDefinition, cache:IInstanceCache, instance:*, referenceResolvers:Vector.<IReferenceResolver>, objectPostProcessors:Vector.<IObjectPostProcessor>):void {
			objectName ||= objectDefinition.className;

			prepareSingleton(objectDefinition, cache, instance, objectName);

			// Autowire happens before setting all explicitly configured properties
			// so that autowired properties can be overridden.
			autowireInstance(instance, objectName, objectDefinition);

			setPropertiesFromObjectDefinition(instance, objectDefinition, objectName, referenceResolvers);

			if (!objectDefinition.skipPostProcessors) {
				postProcessingBeforeInitialization(instance, objectName, objectPostProcessors);
			}

			checkDependencies(objectDefinition, instance, objectName);

			initializeInstance(instance, objectDefinition);

			executeMethodInvocations(objectDefinition, instance, referenceResolvers);

			if (!objectDefinition.skipPostProcessors) {
				postProcessingAfterInitialization(instance, objectName, objectPostProcessors);
			}

			cacheSingleton(objectDefinition, cache, objectName, instance);
		}

		protected function wireWithoutObjectDefinition(instance:*, objectName:String, objectProcessors:Vector.<IObjectPostProcessor>):void {
			// resolve object name
			if (!StringUtils.hasText(objectName)) {
				if (instance.hasOwnProperty(ID_FIELD_NAME)) {
					objectName = instance[ID_FIELD_NAME];
				} else {
					objectName = DEFAULT_OBJECTNAME;
				}
			}

			autowireInstance(instance, objectName);

			postProcessingBeforeInitialization(instance, objectName, objectProcessors);
			if (instance is IInitializingObject) {
				IInitializingObject(instance).afterPropertiesSet();
			}
			postProcessingAfterInitialization(instance, objectName, objectProcessors);
		}
	}
}
