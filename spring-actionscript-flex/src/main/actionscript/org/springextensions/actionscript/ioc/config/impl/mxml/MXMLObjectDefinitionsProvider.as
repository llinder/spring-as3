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
package org.springextensions.actionscript.ioc.config.impl.mxml {

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.reflect.Accessor;
	import org.as3commons.reflect.Field;
	import org.as3commons.reflect.Type;
	import org.as3commons.reflect.Variable;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.impl.mxml.component.MXMLObjectDefinition;
	import org.springextensions.actionscript.ioc.config.impl.mxml.component.SASObjects;
	import org.springextensions.actionscript.ioc.config.impl.mxml.component.PropertyPlaceholder;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;


	/**
	 *
	 * @author Roland Zwaga
	 */
	public class MXMLObjectDefinitionsProvider implements IObjectDefinitionsProvider, IDisposable, IApplicationContextAware {
		private static const UNDERSCORE_CHAR:String = "_";
		private var _applicationContext:IApplicationContext;
		private var _isDisposed:Boolean;
		private var _objectDefinitions:Object;
		private var _propertyURIs:Vector.<TextFileURI>;
		private var _propertiesProvider:IPropertiesProvider;
		private var _configurations:Vector.<Class>;

		/**
		 * Creates a new <code>MXMLObjectDefinitionsProvider</code> instance.
		 */
		public function MXMLObjectDefinitionsProvider() {
			super();
			_objectDefinitions = {};
		}

		/**
		 * @inheritDoc
		 */
		public function createDefinitions():IOperation {
			for each (var cls:Class in _configurations) {
				createDefinitionsFromConfigClass(cls);
			}
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectDefinitions():Object {
			return _objectDefinitions;
		}

		/**
		 * @inheritDoc
		 */
		public function get propertyURIs():Vector.<TextFileURI> {
			return _propertyURIs;
		}

		/**
		 * @inheritDoc
		 */
		public function get propertiesProvider():IPropertiesProvider {
			return _propertiesProvider;
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
		public function dispose():void {
			if (!isDisposed) {
				_isDisposed = true;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get applicationContext():IApplicationContext {
			return _applicationContext;
		}

		/**
		 * @private
		 */
		public function set applicationContext(value:IApplicationContext):void {
			_applicationContext = value;
		}

		/**
		 *
		 * @param clazz
		 */
		public function addConfiguration(clazz:Class):void {
			_configurations ||= new Vector.<Class>();
			if (_configurations.indexOf(clazz) < 0) {
				_configurations[_configurations.length] = clazz;
			}
		}

		/**
		 *
		 * @param cls
		 */
		protected function createDefinitionsFromConfigClass(cls:Class):void {
			var instance:* = new cls();
			if (instance is SASObjects) {
				extractObjectDefinitionsFromConfigInstance(SASObjects(instance));
			}
		}

		/**
		 *
		 * @param config
		 */
		protected function extractObjectDefinitionsFromConfigInstance(config:SASObjects):void {
			var type:Type = Type.forInstance(config, _applicationContext.applicationDomain);

			// read top-level attributes
			var mxmlObjects:SASObjects = SASObjects(config);
			/*result.defaultInitMethod = mxmlObjects.defaultInitMethod;
			result.defaultLazyInit = mxmlObjects.defaultLazyInit;
			result.defaultAutowire = AutowireMode.fromName(mxmlObjects.defaultAutowire);*/

			// parse accessors = definitions that have an id
			for each (var accessor:Accessor in type.accessors) {
				// an accessor is only valid if:
				// - it is readable
				// - it is writable
				// - its declaring class is not SASObjects: we don't want to parse the "defaultLazyInit" property, etc
				if (accessor.readable && accessor.writeable && (accessor.declaringType.clazz == type.clazz)) {
					parseObjectDefinition(_objectDefinitions, config, accessor);
				}
			}

			// parse variables = definitions that don't have an id (name)
			for each (var variable:Variable in type.variables) {
				// a variable is only valid if:
				// - its (generated) id/name matches the pattern '_{CONTEXT_CLASS}_{VARIABLE_CLASS}{N}'
				if ((variable.name.indexOf(UNDERSCORE_CHAR + type.name) > -1) && (variable.declaringType.clazz == type.clazz)) {
					parseObjectDefinition(_objectDefinitions, config, variable);
				}
			}
		}

		/**
		 *
		 * @param definitions
		 * @param config
		 * @param field
		 */
		protected function parseObjectDefinition(definitions:Object, config:Object, field:Field):void {
			var result:IObjectDefinition;
			var instance:Object = config[field.name];

			if (instance is MXMLObjectDefinition) {
				var mxmlDefinition:MXMLObjectDefinition = MXMLObjectDefinition(instance);
				mxmlDefinition.parse();
				_applicationContext.objectDefinitionRegistry.registerObjectDefinition(field.name, mxmlDefinition.definition);
				for (var name:String in mxmlDefinition.objectDefinitions) {
					_applicationContext.objectDefinitionRegistry.registerObjectDefinition(name, IObjectDefinition(mxmlDefinition.objectDefinitions[name]));
				}
			} else if (instance is PropertyPlaceholder) {
				_propertyURIs ||= new Vector.<TextFileURI>();
				_propertyURIs[_propertyURIs.length] = PropertyPlaceholder(instance).toTextFileURI();
			} else if (instance is ICustomObjectDefinitionComponent) {
				ICustomObjectDefinitionComponent(instance).execute(applicationContext);
			} else {
				// register a singleton for an explicit config object defined in mxml
				// for instance: <mx:RemoteObject/>,
				// or just a simple public property set to an object instance: public var myComplexSingleton:ComplextClass = new ComplextClass();
				_applicationContext.cache.addInstance(field.name, instance);
			}
		}

	}
}
