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
	import org.as3commons.lang.ICloneable;


	/**
	 * Describes the the configuration of a single instance property.
	 * @author Roland Zwaga
	 */
	public class PropertyDefinition implements ICloneable {

		private var _name:String;
		private var _namespaceURI:String;
		private var _value:*;
		private var _isStatic:Boolean;
		private var _qName:QName;

		public function get qName():QName {
			_qName ||= new QName(_namespaceURI, _name);
			return _qName;
		}

		public function get namespaceURI():String {
			return _namespaceURI;
		}

		public function get name():String {
			return _name;
		}

		public function set name(value:String):void {
			_name = value;
		}

		public function get value():* {
			return _value;
		}

		public function set value(value:*):void {
			_value = value;
		}

		public function get isStatic():Boolean {
			return _isStatic;
		}

		public function set isStatic(value:Boolean):void {
			_isStatic = value;
		}

		public function PropertyDefinition(propertyName:String, propertyValue:*, ns:String=null, propertyIsStatic:Boolean=false) {
			super();
			initPropertyDefinition(propertyName, propertyValue, ns, propertyIsStatic);
		}

		protected function initPropertyDefinition(propertyName:String, propertyValue:*, ns:String, propertyIsStatic:Boolean):void {
			_name = propertyName;
			_value = propertyValue;
			_namespaceURI = ns;
			_isStatic = propertyIsStatic;
		}

		public function clone():* {
			return new PropertyDefinition(this.name, this.value, this.namespaceURI, this.isStatic);
		}

		public function toString():String {
			return "PropertyDefinition{_name:\"" + _name + "\", _namespaceURI:\"" + _namespaceURI + "\", _value:" + _value + ", _isStatic:" + _isStatic + "}";
		}


	}
}
