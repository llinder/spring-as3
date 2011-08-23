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
package org.springextensions.actionscript.ioc.config.impl.mxml.component {
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;

	[DefaultProperty("value")]
	/**
	 * MXML representation of a <code>Property</code> object. This non-visual component must be declared as
	 * a child component of a <code>ObjectDefinition</code> component.
	 * @see org.springextensions.actionscript.context.support.mxml.MXMLObjectDefinition ObjectDefinition
	 * @author Roland Zwaga
	 */
	public class Property extends Arg {

		/**
		 * Creates a new <code>Property</code> instance
		 */
		public function Property() {
			super();
		}

		private var _isStatic:Boolean = false;

		private var _name:String;
		private var _namespaceURI:String;

		public function get isStatic():Boolean {
			return _isStatic;
		}

		public function set isStatic(value:Boolean):void {
			_isStatic = value;
		}

		/**
		 * The name of the property
		 */
		public function get name():String {
			return _name;
		}

		/**
		 * @private
		 */
		public function set name(value:String):void {
			_name = value;
		}

		public function get namespaceURI():String {
			return _namespaceURI;
		}

		public function set namespaceURI(value:String):void {
			_namespaceURI = value;
		}

		/**
		 * @inheritDoc
		 */
		override public function clone():* {
			var clone:Property = new Property();
			clone.name = this.name;
			clone.ref = this.ref;
			clone.type = this.type;
			clone.value = this.value;
			clone.namespaceURI = this.namespaceURI;
			return clone;
		}

		public function toPropertyDefinition():PropertyDefinition {
			return new PropertyDefinition(_name, value, _namespaceURI, _isStatic);
		}
	}
}
