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

	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;


	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultObjectDefinitionRegistry implements IObjectDefinitionRegistry {

		private var _objectFactory:IObjectFactory;
		private var _objectDefinitions:Object;

		public function DefaultObjectDefinitionRegistry() {
			super();
		}

		public function get objectDefinitionNames():Vector.<String> {
			return null;
		}

		public function get numObjectDefinitions():uint {
			return 0;
		}

		public function containsObject(objectName:String):Boolean {
			return false;
		}

		public function isSingleton(objectName:String):Boolean {
			return false;
		}

		public function isPrototype(objectName:String):Boolean {
			return false;
		}

		public function getType(objectName:String):Class {
			return null;
		}

		public function registerObjectDefinition(objectName:String, objectDefinition:IObjectDefinition):void {
		}

		public function removeObjectDefinition(objectName:String):void {
		}

		public function getObjectDefinition(objectName:String):IObjectDefinition {
			return null;
		}

		public function containsObjectDefinition(objectName:String):Boolean {
			return false;
		}

		public function getObjectDefinitionsOfType(type:Class):Vector.<IObjectDefinition> {
			return null;
		}

		public function getObjectNamesForType(type:Class):Vector.<String> {
			return null;
		}

		public function getUsedTypes():Vector.<Class> {
			return null;
		}

		public function getObjectDefinitionsWithMetadata(metadataNames:Vector.<String>):Vector.<IObjectDefinition> {
			return null;
		}

		public function set objectFactory(objectFactory:IObjectFactory):void {
			_objectFactory = objectFactory;
		}

		public function get objectDefinitions():Object {
			return _objectDefinitions;
		}
	}
}
