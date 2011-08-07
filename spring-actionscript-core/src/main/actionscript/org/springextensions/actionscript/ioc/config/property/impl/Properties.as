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
package org.springextensions.actionscript.ioc.config.property.impl {

	import flash.events.Event;
	import org.as3commons.lang.ObjectUtils;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesParser;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;

	/**
	 * The <code>Properties</code> class represents a collection of properties
	 * in the form of key-value pairs. All keys and values are of type
	 * <code>String</code>
	 *
	 * @author Christophe Herreman
	 * @author Roland Zwaga
	 */
	public class Properties implements IPropertiesProvider {
		private static const QUESTION_MARK:String = '?';
		private static const AMPERSAND:String = "&";

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>Properties</code> object.
		 */
		public function Properties() {
			super();
			initProperties();
		}

		private var _content:Object;
		private var _propertyNames:Vector.<String>;

		/**
		 * The content of the Properties instance as an object.
		 * @return an object containing the content of the properties
		 */
		public function get content():Object {
			return _content;
		}

		/**
		 * Adds a random number to the url, checks if a '?' character is already part of the string
		 * than suffixes a '&amp;' character
		 * @param url The url that will be processed
		 * @param preventCache
		 * @return The formatted URL
		 */
		public function formatURL(url:String, preventCache:Boolean):String {
			if (preventCache) {
				var parameterAppendChar:String = (url.indexOf(QUESTION_MARK) < 0) ? QUESTION_MARK : AMPERSAND;
				url += (parameterAppendChar + Math.round(Math.random() * 1000000));
			}
			return url;
		}

		// --------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------

		/**
		 * Gets the value of property that corresponds to the given <code>key</code>.
		 * If no property was found, <code>null</code> is returned.
		 *
		 * @param key the name of the property to get
		 * @returns the value of the property with the given key, or null if none was found
		 */
		public function getProperty(key:String):* {
			return _content[key];
		}

		public function hasProperty(key:String):Boolean {
			return _content.hasOwnProperty(key);
		}

		public function get length():uint {
			return _propertyNames.length;
		}

		/**
		 * Adds all conIPropertiese given properties object to this Properties.
		 */
		public function merge(properties:IPropertiesProvider, overrideProperty:Boolean = false):void {
			if ((!properties) || (properties === this)) {
				return;
			}

			for (var key:String in properties.content) {
				if (!_content[key] || (_content[key] && overrideProperty)) {
					addPropertyName(key);
					_content[key] = properties.content[key];
				}
			}
		}

		/**
		 * Returns an array with the keys of all properties. If no properties
		 * were found, an empty array is returned.
		 *
		 * @return an array with all keys
		 */
		public function get propertyNames():Vector.<String> {
			return _propertyNames;
		}

		/**
		 * Sets a property. If the property with the given key already exists,
		 * it will be replaced by the new value.
		 *
		 * @param key the key of the property to set
		 * @param value the value of the property to set
		 */
		public function setProperty(key:String, value:String):void {
			addPropertyName(key);
			_content[key] = value;
		}

		protected function addPropertyName(key:String):void {
			if (_propertyNames.indexOf(key) < 0) {
				_propertyNames[_propertyNames.length] = key;
			}
		}

		protected function initProperties():void {
			_content = {};
			_propertyNames = new Vector.<String>();
		}
	}
}
