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
package org.springextensions.actionscript.ioc.objectdefinition {
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	/**
	 *
	 * @author Roland Zwaga
	 *
	 */
	public final class ObjectDefinitionAccess {

		private static const _INSTANCES:Dictionary = new Dictionary();
		private static var _enumCreated:Boolean;

		public static const PRIVATE:ObjectDefinitionAccess = new ObjectDefinitionAccess(PRIVATE_NAME);
		public static const PUBLIC:ObjectDefinitionAccess = new ObjectDefinitionAccess(PUBLIC_NAME);

		private static const PRIVATE_NAME:String = "privateObjectDefinitionAccess";
		private static const PUBLIC_NAME:String = "publicObjectDefinitionAccess";

		{
			_enumCreated = true;
		}

		private var _value:String;

		public function get value():String {
			return _value;
		}

		public function ObjectDefinitionAccess(val:String) {
			super();
			if (_enumCreated) {
				throw new IllegalOperationError("ObjectDefinitionAccess has already been created");
			}
			_value = value;
			_INSTANCES[val] = this;
		}

		public static function fromValue(val:String):ObjectDefinitionAccess {
			return _INSTANCES[val] as ObjectDefinitionAccess;
		}
	}
}
