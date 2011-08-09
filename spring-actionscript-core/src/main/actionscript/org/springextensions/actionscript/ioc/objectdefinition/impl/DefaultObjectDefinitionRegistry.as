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
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultObjectDefinitionRegistry implements IObjectDefinitionRegistry, IDisposable, IApplicationDomainAware {

		private var _objectDefinitions:Object;
		private var _objectDefinitionNameLookup:Dictionary;
		private var _objectDefinitionList:Vector.<IObjectDefinition>;
		private var _objectDefinitionMetadataLookup:Dictionary;
		private var _objectDefinitionNames:Vector.<String>;
		private var _objectDefinitionClasses:Vector.<Class>;
		private var _isDisposed:Boolean;
		private var _applicationDomain:ApplicationDomain;

		/**
		 * Creates a new <code>DefaultObjectDefinitionRegistry</code> instance.
		 *
		 */
		public function DefaultObjectDefinitionRegistry() {
			super();
			initDefaultObjectDefinitionRegistry();
		}

		protected function initDefaultObjectDefinitionRegistry():void {
			_objectDefinitions = {};
			_objectDefinitionList = new Vector.<IObjectDefinition>();
			_objectDefinitionNames = new Vector.<String>();
			_objectDefinitionClasses = new Vector.<Class>();
			_objectDefinitionMetadataLookup = new Dictionary();
			_objectDefinitionNameLookup = new Dictionary();
		}

		public function containsObjectDefinition(objectName:String):Boolean {
			return _objectDefinitions.hasOwnProperty(objectName);
		}

		public function getObjectDefinition(objectName:String):IObjectDefinition {
			return _objectDefinitions[objectName] as IObjectDefinition;
		}

		public function getObjectDefinitionsForType(type:Class):Vector.<IObjectDefinition> {
			var result:Vector.<IObjectDefinition>;
			for each (var definition:IObjectDefinition in _objectDefinitionList) {
				if (ClassUtils.isAssignableFrom(definition.clazz, type, _applicationDomain)) {
					result ||= new Vector.<IObjectDefinition>();
					result[result.length] = definition;
				}
			}
			return result;
		}

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

		public function getObjectNamesForType(type:Class):Vector.<String> {
			var result:Vector.<String>;
			for each (var name:String in _objectDefinitionNames) {
				var definition:IObjectDefinition = getObjectDefinition(name);
				if (ClassUtils.isAssignableFrom(definition.clazz, type, _applicationDomain)) {
					result ||= new Vector.<String>();
					result[result.length] = name;
				}
			}
			return result;
		}

		public function getType(objectName:String):Class {
			var objectDefinition:IObjectDefinition = getObjectDefinition(objectName);
			if (objectDefinition != null) {
				return ClassUtils.forName(objectDefinition.className, _applicationDomain);
			} else {
				return null;
			}
		}

		public function getUsedTypes():Vector.<Class> {
			return _objectDefinitionClasses;
		}

		public function isPrototype(objectName:String):Boolean {
			var objectDefinition:IObjectDefinition = getObjectDefinition(objectName);
			return (objectDefinition != null) ? !objectDefinition.isSingleton : false;
		}

		public function isSingleton(objectName:String):Boolean {
			return !(isPrototype(objectName));
		}

		public function get numObjectDefinitions():uint {
			return _objectDefinitionNames.length;
		}

		public function get objectDefinitionNames():Vector.<String> {
			return _objectDefinitionNames;
		}

		public function registerObjectDefinition(objectName:String, objectDefinition:IObjectDefinition):void {
			if (!containsObjectDefinition(objectName)) {
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
			} else {
				throw new Error("Object definition with that name already exists");
			}
		}

		protected function addToMetadataLookup(objectDefinition:IObjectDefinition):void {
			var type:Type = Type.forName(objectDefinition.className, _applicationDomain);
			for each (var metadata:Metadata in type.metadata) {
				var name:String = metadata.name.toLowerCase();
				_objectDefinitionMetadataLookup[name] ||= new Vector.<IObjectDefinition>();
				_objectDefinitionMetadataLookup[name].push(objectDefinition);
			}
		}

		public function removeObjectDefinition(objectName:String):void {
			throw new Error("Not implemented yet!");
		}

		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		public function dispose():void {
			if (!_isDisposed) {
				_objectDefinitions = null;
				_objectDefinitionNames = null;
				_objectDefinitionClasses = null;
				_objectDefinitionMetadataLookup = null;
				_objectDefinitionList = null;
				_objectDefinitionNames = null;
				_isDisposed = true;
			}
		}

		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}

		public function getObjectDefinitionName(objectDefinition:IObjectDefinition):String {
			return _objectDefinitionNameLookup[objectDefinition] as String;
		}

	}
}
