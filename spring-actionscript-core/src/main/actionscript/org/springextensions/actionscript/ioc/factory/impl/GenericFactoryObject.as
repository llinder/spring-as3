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

	import org.as3commons.reflect.MethodInvoker;
	import org.springextensions.actionscript.ioc.factory.IFactoryObject;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class GenericFactoryObject implements IFactoryObject {
		private static const CONSTRUCTOR_FIELD_NAME:String = "constructor";
		private var _objectType:Class;
		private var _methodInvoker:MethodInvoker;
		private var _isSingleton:Boolean;
		private var _singletonInstance:*;

		/**
		 * Creates a new <code>GenericFactoryObject</code> instance.
		 */
		public function GenericFactoryObject(wrappedFactory:Object, methodName:String, singleton:Boolean=true) {
			super();
			initGenericFactoryObject(wrappedFactory, methodName, singleton);
		}

		protected function initGenericFactoryObject(wrappedFactory:Object, methodName:String, singleton:Boolean):void {
			_methodInvoker = new MethodInvoker();
			_methodInvoker.target = wrappedFactory;
			_methodInvoker.method = methodName;
			_isSingleton = singleton;
		}

		public function getObject():* {
			if (_singletonInstance != null) {
				return _singletonInstance;
			} else {
				return createInstance();
			}
		}

		protected function createInstance():* {
			var result:* = _methodInvoker.invoke();
			if (_objectType == null) {
				if (Object(result).hasOwnProperty(CONSTRUCTOR_FIELD_NAME)) {
					_objectType = Object(result)[CONSTRUCTOR_FIELD_NAME] as Class;
				}
			}
			if (_isSingleton) {
				_singletonInstance = result;
			}
			return result;
		}


		public function getObjectType():Class {
			return _objectType;
		}

		public function get isSingleton():Boolean {
			return _isSingleton;
		}
	}
}