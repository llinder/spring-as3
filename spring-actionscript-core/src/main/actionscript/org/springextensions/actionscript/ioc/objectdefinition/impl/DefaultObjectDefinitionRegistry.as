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
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultObjectDefinitionRegistry implements IObjectDefinitionRegistry, IDisposable, IApplicationDomainAware {

		private var _objectDefinitions:Object;
		private var _objectDefinitionClassLookup:Dictionary;
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
			_objectDefinitionNames = new Vector.<String>();
			_objectDefinitionClasses = new Vector.<Class>();
			_objectDefinitionClassLookup = new Dictionary();
			_objectDefinitionMetadataLookup = new Dictionary();
		}

		public function containsObjectDefinition(objectName:String):Boolean {
			return _objectDefinitions.hasOwnProperty(objectName);
		}

		public function getObjectDefinition(objectName:String):IObjectDefinition {
			return _objectDefinitions[objectName] as IObjectDefinition;
		}

		public function getObjectDefinitionsOfType(type:Class):Vector.<IObjectDefinition> {
			return null;
		}

		public function getObjectDefinitionsWithMetadata(metadataNames:Vector.<String>):Vector.<IObjectDefinition> {
			return null;
		}

		public function getObjectNamesForType(type:Class):Vector.<String> {
			return null;
		}

		public function getType(objectName:String):Class {
			return null;
			//return ClassUtils.forName(
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
				_objectDefinitions[objectName] = objectDefinition;
				_objectDefinitionNames[_objectDefinitionNames.length] = objectName;
				var cls:Class = ClassUtils.forName(objectDefinition.className, _applicationDomain);

			} else {
				throw new Error("Object definition with that name already exists");
			}
		}

		public function removeObjectDefinition(objectName:String):void {
		}

		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		public function dispose():void {
			if (!_isDisposed) {
				_objectDefinitions = null;
				_objectDefinitionNames = null;
				_objectDefinitionClasses = null;
				_objectDefinitionClassLookup = null;
				_objectDefinitionMetadataLookup = null;
				_isDisposed = true;
			}
		}

		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}
	}
}
