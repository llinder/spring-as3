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
package org.springextensions.actionscript.ioc.objectdefinition.impl {
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.reflect.Metadata;
	import org.as3commons.reflect.Type;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.util.ContextUtils;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultObjectDefinitionRegistry implements IObjectDefinitionRegistry, IDisposable, IApplicationDomainAware {
		private static const CHARACTERS:String = "abcdefghijklmnopqrstuvwxys";
		private static const IS_SINGLETON_FIELD_NAME:String = "isSingleton";
		private static const OBJECT_DEFINITION_NAME_EXISTS_ERROR:String = "Object definition with that name has already been registered";

		public static function generateRegistryId():String {
			var len:int = 20;
			var result:Array = new Array(20);
			while (len) {
				result[len--] = CHARACTERS.charAt(Math.floor(Math.random() * 26));
			}
			return result.join('');
		}

		/**
		 * Creates a new <code>DefaultObjectDefinitionRegistry</code> instance.
		 *
		 */
		public function DefaultObjectDefinitionRegistry() {
			super();
			initDefaultObjectDefinitionRegistry();
		}

		private var _applicationDomain:ApplicationDomain;
		private var _customConfigurations:Object;
		private var _id:String;
		private var _isDisposed:Boolean;
		private var _objectDefinitionClasses:Vector.<Class>;
		private var _objectDefinitionList:Vector.<IObjectDefinition>;
		private var _objectDefinitionMetadataLookup:Dictionary;
		private var _objectDefinitionNameLookup:Dictionary;
		private var _objectDefinitionNames:Vector.<String>;
		private var _objectDefinitions:Object;

		/**
		 * @inheritDoc
		 */
		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get id():String {
			return _id;
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
		public function get numObjectDefinitions():uint {
			return _objectDefinitionNames.length;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectDefinitionNames():Vector.<String> {
			return _objectDefinitionNames;
		}

		/**
		 * @inheritDoc
		 */
		public function containsObjectDefinition(objectName:String):Boolean {
			return _objectDefinitions.hasOwnProperty(objectName);
		}

		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			if (!_isDisposed) {
				for each (var name:String in _objectDefinitionNames) {
					var objectDefinition:IObjectDefinition = IObjectDefinition(_objectDefinitions[name]);
					if (objectDefinition.registryId == _id) {
						ContextUtils.disposeInstance(objectDefinition);
					}
				}
				_objectDefinitions = null;
				_objectDefinitionNames = null;
				_objectDefinitionClasses = null;
				_objectDefinitionMetadataLookup = null;
				_objectDefinitionList = null;
				_objectDefinitionNames = null;
				_customConfigurations = null;
				_isDisposed = true;
			}
		}

		public function getCustomConfiguration(objectName:String):* {
			return (_customConfigurations != null) ? _customConfigurations[objectName] : null;
		}

		/**
		 * @inheritDoc
		 */
		public function getDefinitionNamesWithPropertyValue(propertyName:String, propertyValue:*, returnMatching:Boolean=true):Vector.<String> {
			var result:Vector.<String>;
			for each (var name:String in _objectDefinitionNames) {
				var definition:IObjectDefinition = getObjectDefinition(name);
				var match:Boolean = ((definition[propertyName] == propertyValue) && (returnMatching));
				if (match) {
					result ||= new Vector.<String>();
					result[result.length] = name;
				}
			}
			return result;
		}

		/**
		 * @inheritDoc
		 */
		public function getObjectDefinition(objectName:String):IObjectDefinition {
			return _objectDefinitions[objectName] as IObjectDefinition;
		}

		/**
		 * @inheritDoc
		 */
		public function getObjectDefinitionName(objectDefinition:IObjectDefinition):String {
			return _objectDefinitionNameLookup[objectDefinition] as String;
		}

		/**
		 * @inheritDoc
		 */
		public function getObjectDefinitionsForType(type:Class):Vector.<IObjectDefinition> {
			var result:Vector.<IObjectDefinition>;
			for each (var definition:IObjectDefinition in _objectDefinitionList) {
				if (ClassUtils.isAssignableFrom(type, definition.clazz, _applicationDomain)) {
					result ||= new Vector.<IObjectDefinition>();
					result[result.length] = definition;
				}
			}
			return result;
		}

		/**
		 * @inheritDoc
		 */
		public function getObjectDefinitionsWithMetadata(metadataNames:Vector.<String>):Vector.<IObjectDefinition> {
			var result:Vector.<IObjectDefinition>;
			for each (var name:String in metadataNames) {
				name = name.toLowerCase();
				var list:Vector.<IObjectDefinition> = _objectDefinitionMetadataLookup[name] as Vector.<IObjectDefinition>;
				if (list != null) {
					result ||= new Vector.<IObjectDefinition>();
					result = result.concat(list);
				}
			}
			return result;
		}

		/**
		 * @inheritDoc
		 */
		public function getObjectNamesForType(type:Class):Vector.<String> {
			var result:Vector.<String>;
			for each (var name:String in _objectDefinitionNames) {
				var definition:IObjectDefinition = getObjectDefinition(name);
				if (ClassUtils.isAssignableFrom(type, definition.clazz, _applicationDomain)) {
					result ||= new Vector.<String>();
					result[result.length] = name;
				}
			}
			return result;
		}

		/**
		 * @inheritDoc
		 */
		public function getPrototypes():Vector.<String> {
			return getDefinitionNamesWithPropertyValue(IS_SINGLETON_FIELD_NAME, false);
		}

		/**
		 * @inheritDoc
		 */
		public function getSingletons(lazyInit:Boolean=false):Vector.<String> {
			var result:Vector.<String>;
			for each (var name:String in _objectDefinitionNames) {
				var definition:IObjectDefinition = getObjectDefinition(name);
				if ((definition.isSingleton) && (definition.isLazyInit == lazyInit)) {
					result ||= new Vector.<String>();
					result[result.length] = name;
				}
			}
			return result;
		}

		/**
		 * @inheritDoc
		 */
		public function getType(objectName:String):Class {
			var objectDefinition:IObjectDefinition = getObjectDefinition(objectName);
			if (objectDefinition != null) {
				return ClassUtils.forName(objectDefinition.className, _applicationDomain);
			} else {
				return null;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function getUsedTypes():Vector.<Class> {
			return _objectDefinitionClasses;
		}

		/**
		 * @inheritDoc
		 */
		public function isPrototype(objectName:String):Boolean {
			var objectDefinition:IObjectDefinition = getObjectDefinition(objectName);
			return (objectDefinition != null) ? !objectDefinition.isSingleton : false;
		}

		/**
		 * @inheritDoc
		 */
		public function isSingleton(objectName:String):Boolean {
			return !(isPrototype(objectName));
		}

		public function registerCustomConfiguration(objectName:String, configuration:*):void {
			if (containsObjectDefinition(objectName)) {
				var objectDefinition:IObjectDefinition = getObjectDefinition(objectName);
				objectDefinition.customConfiguration = configuration;
			} else {
				_customConfigurations ||= {};
				_customConfigurations[objectName] = configuration;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function registerObjectDefinition(objectName:String, objectDefinition:IObjectDefinition, override:Boolean=true):void {
			var contains:Boolean = containsObjectDefinition(objectName);
			if (contains && override) {
				removeObjectDefinition(objectName);
			} else if (contains && !override) {
				throw new Error(OBJECT_DEFINITION_NAME_EXISTS_ERROR);
			}
			objectDefinition.registryId = id;
			_objectDefinitionNameLookup[objectDefinition] = objectName;
			_objectDefinitionList[_objectDefinitionList.length] = objectDefinition;
			_objectDefinitions[objectName] = objectDefinition;
			_objectDefinitionNames[_objectDefinitionNames.length] = objectName;
			addToMetadataLookup(objectDefinition);
			var cls:Class = (objectDefinition.clazz == null) ? ClassUtils.forName(objectDefinition.className, _applicationDomain) : objectDefinition.clazz;
			if (_objectDefinitionClasses.indexOf(cls) < 0) {
				_objectDefinitionClasses[_objectDefinitionClasses.length] = cls;
			}
			objectDefinition.clazz = cls;
			objectDefinition.isInterface = ClassUtils.isInterface(cls);
			if ((_customConfigurations != null) && (_customConfigurations.hasOwnProperty(objectName))) {
				objectDefinition.customConfiguration = _customConfigurations[objectName];
				delete _customConfigurations[objectName];
			}

		}

		/**
		 * @inheritDoc
		 */
		public function removeObjectDefinition(objectName:String):void {
			if (containsObjectDefinition(objectName)) {
				var definition:IObjectDefinition = getObjectDefinition(objectName);
				var idx:int;
				var list:Vector.<String> = getObjectNamesForType(definition.clazz);
				var deleteClass:Boolean = ((list != null) && (list.length == 1));
				if (deleteClass) {
					idx = _objectDefinitionClasses.indexOf(definition.clazz);
					if (idx > -1) {
						_objectDefinitionClasses.splice(idx, 1);
					}
				}
				var type:Type = Type.forName(definition.className, _applicationDomain);
				for each (var metadata:Metadata in type.metadata) {
					var name:String = metadata.name.toLowerCase();
					removeFromMetadataLookup(name, definition);
				}
				delete _objectDefinitionNameLookup[definition];
				idx = _objectDefinitionList.indexOf(definition);
				if (idx > -1) {
					_objectDefinitionList.splice(idx, 1);
				}
				delete _objectDefinitions[objectName];
				idx = _objectDefinitionNames.indexOf(objectName);
				if (idx > -1) {
					_objectDefinitionNames.splice(idx, 1);
				}
			}
		}

		/**
		 *
		 * @param objectDefinition
		 */
		protected function addToMetadataLookup(objectDefinition:IObjectDefinition):void {
			var type:Type = Type.forName(objectDefinition.className, _applicationDomain);
			for each (var metadata:Metadata in type.metadata) {
				var name:String = metadata.name.toLowerCase();
				_objectDefinitionMetadataLookup[name] ||= new Vector.<IObjectDefinition>();
				_objectDefinitionMetadataLookup[name].push(objectDefinition);
			}
		}

		/**
		 *
		 */
		protected function initDefaultObjectDefinitionRegistry():void {
			_objectDefinitions = {};
			_objectDefinitionList = new Vector.<IObjectDefinition>();
			_objectDefinitionNames = new Vector.<String>();
			_objectDefinitionClasses = new Vector.<Class>();
			_objectDefinitionMetadataLookup = new Dictionary();
			_objectDefinitionNameLookup = new Dictionary();
			_id = generateRegistryId();
		}

		/**
		 *
		 * @param name
		 * @param definition
		 */
		protected function removeFromMetadataLookup(name:String, definition:IObjectDefinition):void {
			var list:Vector.<IObjectDefinition> = _objectDefinitionMetadataLookup[name];
			if (list != null) {
				var idx:int = list.indexOf(definition);
				if (idx > -1) {
					list.splice(idx, 1);
				}
				if (list.length == 0) {
					delete _objectDefinitionMetadataLookup[name];
				}
			}
		}
	}
}
