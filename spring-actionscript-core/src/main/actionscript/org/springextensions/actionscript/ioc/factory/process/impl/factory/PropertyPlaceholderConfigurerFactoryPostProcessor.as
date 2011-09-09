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
package org.springextensions.actionscript.ioc.factory.process.impl.factory {

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.lang.IOrdered;
	import org.as3commons.lang.ObjectUtils;
	import org.as3commons.reflect.Accessor;
	import org.as3commons.reflect.Type;
	import org.as3commons.reflect.Variable;
	import org.springextensions.actionscript.ioc.config.impl.RuntimeObjectReference;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.IPropertyPlaceholderResolver;
	import org.springextensions.actionscript.ioc.config.property.impl.PropertyPlaceholderResolver;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;

	/**
	 * @author Christophe Herreman
	 */
	public class PropertyPlaceholderConfigurerFactoryPostProcessor extends AbstractOrderedFactoryPostProcessor {

		// --------------------------------------------------------------------
		//
		// Private Constants
		//
		// --------------------------------------------------------------------

		/** Regular expression to resolve property placeholder with the pattern ${...} */
		public static const PROPERTY_REGEXP:RegExp = /\$\{[^}]+\}/g;

		/** Regular expression to resolve property placeholder with the pattern $(...) */
		public static const PROPERTY_REGEXP2:RegExp = /\$\([^)]+\)/g;

		// --------------------------------------------------------------------
		//
		// Private Variables
		//
		// --------------------------------------------------------------------

		/** The object factory that this post processor operates on. */
		private var _objectFactory:IObjectFactory;

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>PropertyPlaceholderConfigurer</code> instance.
		 */
		public function PropertyPlaceholderConfigurerFactoryPostProcessor(orderPosition:int) {
			super(orderPosition);
		}

		// --------------------------------------------------------------------
		//
		// Public Properties
		//
		// --------------------------------------------------------------------

		// ----------------------------
		// properties
		// ----------------------------

		private var _properties:IPropertiesProvider;

		public function get properties():IPropertiesProvider {
			return _properties;
		}

		public function set properties(value:IPropertiesProvider):void {
			_properties = value;
		}

		// ----------------------------
		// ignoreUnresolvablePlaceholders
		// ----------------------------

		private var _ignoreUnresolvablePlaceholders:Boolean = false;

		/**
		 * Sets whether to ignore unresolvable placeholders. Default is "false":
		 * An exception will be thrown if a placeholder cannot be resolved.
		 */
		public function set ignoreUnresolvablePlaceholders(value:Boolean):void {
			if (value != _ignoreUnresolvablePlaceholders) {
				_ignoreUnresolvablePlaceholders = value;
			}
		}

		// --------------------------------------------------------------------
		//
		// Implementation: IObjectFactoryPostProcessor: Methods
		//
		// --------------------------------------------------------------------

		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation {
			_objectFactory = objectFactory;

			var resolver:IPropertyPlaceholderResolver = new PropertyPlaceholderResolver(null, _properties, _ignoreUnresolvablePlaceholders);

			for each (var objectName:String in objectFactory.objectDefinitionRegistry.objectDefinitionNames) {
				resolvePropertyPlaceholdersForObjectName(resolver, objectName);
			}

			return null;
		}

		// --------------------------------------------------------------------
		//
		// Private Methods
		//
		// --------------------------------------------------------------------

		/**
		 * Resolves all property placeholders for the constructor arguments and the properties of
		 * the specified object definition.
		 *
		 * Note that we use 2 regular expressions (${...} and $(...)) to handle both XML and MXML property
		 * placeholders.
		 *
		 * @param resolver the property placeholder resolver used
		 * @param objectName the name of the definition for which to resolve it property placeholders
		 */
		protected function resolvePropertyPlaceholdersForObjectName(resolver:IPropertyPlaceholderResolver, objectName:String):void {
			//logger.debug("Resolving property placeholders in object definition '{0}'", objectDefinition.className);
			var objectDefinition:IObjectDefinition = _objectFactory.getObjectDefinition(objectName);

			var i:int = 0;
			for each (var constructorArg:* in objectDefinition.constructorArguments) {
				if (constructorArg is String) {
					//logger.debug("Resolving property placeholders in constructor arg '{0}'", constructorArg);
					objectDefinition.constructorArguments[i] = resolver.resolvePropertyPlaceholders(constructorArg, PROPERTY_REGEXP);
					objectDefinition.constructorArguments[i] = resolver.resolvePropertyPlaceholders(objectDefinition.constructorArguments[i], PROPERTY_REGEXP2);
				}
				i++;
			}

			for each (var propDef:PropertyDefinition in objectDefinition.properties) {
				//logger.debug("Resolving property placeholders in property '{0}'", propertyName);
				if (propDef.value is String) {
					//logger.debug("Resolving property placeholders in property '{0}' with value '{1}'", propertyName, properties[propertyName]);
					propDef.value = resolver.resolvePropertyPlaceholders(propDef.value, PROPERTY_REGEXP);
					propDef.value = resolver.resolvePropertyPlaceholders(propDef.value, PROPERTY_REGEXP2);
				} else if (propDef.value is RuntimeObjectReference) {
					var ref:RuntimeObjectReference = RuntimeObjectReference(propDef.value);
					ref.objectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP);
					ref.objectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP2);
				}
			}

			// resolve method invocations
			for each (var mi:MethodInvocation in objectDefinition.methodInvocations) {
				i = 0;
				for each (var arg:Object in mi.arguments) {
					if (arg is String) {
						mi.arguments[i] = resolver.resolvePropertyPlaceholders(String(arg), PROPERTY_REGEXP);
						mi.arguments[i] = resolver.resolvePropertyPlaceholders(String(arg), PROPERTY_REGEXP2);
					} else if (arg is RuntimeObjectReference) {
						var ref:RuntimeObjectReference = RuntimeObjectReference(arg);
						ref.objectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP);
						ref.objectName = resolver.resolvePropertyPlaceholders(ref.objectName, PROPERTY_REGEXP2);
					}
					i++;
				}
			}

			// resolve result of factory method
			if (objectDefinition.factoryObjectName && objectDefinition.factoryMethod && objectDefinition.isSingleton) {
				resolvePropertyPlaceholdersForInstance(resolver, _objectFactory.getObject(objectName));
			}
		}

		/**
		 * Resolves all property placeholders in the given instance.
		 *
		 * @param resolver the property placeholder resolver used
		 * @param instance the instance for which to resolve its property placeholders
		 */
		protected function resolvePropertyPlaceholdersForInstance(resolver:IPropertyPlaceholderResolver, instance:Object):void {
			if (!resolver && !instance) {
				return;
			}

			switch (true) {
				case (instance is Array):
					var array:Array = instance as Array;
					var numItems:uint = array.length;
					for (var i:int = 0; i < numItems; i++) {
						if (array[i] is String) {
							array[i] = resolver.resolvePropertyPlaceholders(array[i], PROPERTY_REGEXP);
							array[i] = resolver.resolvePropertyPlaceholders(array[i], PROPERTY_REGEXP2);
						}
					}
					break;

				default:
					var type:Type = Type.forInstance(instance, _objectFactory.applicationDomain);
					for each (var property:Accessor in type.accessors) {
						if ((property) && (property.type)) {
							if ((property.type.clazz == String) && property.writeable && property.readable) {
								instance[property.name] = resolver.resolvePropertyPlaceholders(instance[property.name], PROPERTY_REGEXP);
								instance[property.name] = resolver.resolvePropertyPlaceholders(instance[property.name], PROPERTY_REGEXP2);
							}
						}
					}
					for each (var variable:Variable in type.variables) {
						if ((variable) && (variable.type)) {
							if (variable.type.clazz == String) {
								instance[variable.name] = resolver.resolvePropertyPlaceholders(instance[variable.name], PROPERTY_REGEXP);
								instance[variable.name] = resolver.resolvePropertyPlaceholders(instance[variable.name], PROPERTY_REGEXP2);
							}
						}
					}
			}

		}

	}
}
