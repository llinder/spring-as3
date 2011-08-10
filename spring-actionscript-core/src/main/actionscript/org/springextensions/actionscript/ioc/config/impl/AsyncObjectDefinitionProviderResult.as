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
package org.springextensions.actionscript.ioc.config.impl {
	import org.springextensions.actionscript.ioc.config.property.PropertyURI;


	/**
	 *
	 * @author Roland Zwaga
	 */
	public final class AsyncObjectDefinitionProviderResult {

		private var _objectDefinitions:Object;
		private var _propertyURIs:Vector.<PropertyURI>;

		/**
		 * Creates a new <code>AsyncObjectDefinitionProviderResult</code> instance.
		 * @param definitions
		 * @param URIs
		 *
		 */
		public function AsyncObjectDefinitionProviderResult(definitions:Object, URIs:Vector.<PropertyURI>=null) {
			super();
			init(definitions, URIs);
		}

		protected function init(definitions:Object, URIs:Vector.<PropertyURI>):void {
			_objectDefinitions = definitions;
			_propertyURIs = URIs;
		}

		public function get objectDefinitions():Object {
			return _objectDefinitions;
		}

		public function get propertyURIs():Vector.<PropertyURI> {
			return _propertyURIs;
		}

	}
}
