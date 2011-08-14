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
package org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl {
	import org.as3commons.lang.Assert;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_objects;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.IXMLObjectDefinitionsPreprocessor;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;
	import org.springextensions.actionscript.util.Environment;

	use namespace spring_actionscript_objects;

	/**
	 * XML Preprocessor for the "import" element that imports external properties files. These nodes are
	 * preprocessed to PropertyPlaceholderConfigurer objects.
	 *
	 * @author Christophe Herreman
	 */
	public class PropertyImportPreprocessor implements IXMLObjectDefinitionsPreprocessor {

		private static const FILE_ATTRIBUTE_NAME:String = 'file';
		private static const REQUIRED_ATTRIBUTE_NAME:String = 'required';
		private static const PREVENTCACHE_ATTRIBUTE_NAME:String = "prevent-cache";
		private var _propertyURIS:Vector.<TextFileURI>;

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 *
		 * @param propURIs
		 */
		public function PropertyImportPreprocessor(propURIs:Vector.<TextFileURI>) {
			super();
			initPropertyImportProcessor(propURIs);
		}

		/**
		 *
		 * @param propURIs
		 *
		 */
		protected function initPropertyImportProcessor(propURIs:Vector.<TextFileURI>):void {
			Assert.notNull(propURIs, "propURIs argument must not be null");
			_propertyURIS = propURIs;
		}


		// --------------------------------------------------------------------
		//
		// Implementation: IXMLObjectDefinitionsPreprocessor: Methods
		//
		// --------------------------------------------------------------------

		public function preprocess(xml:XML):XML {
			var propertyNodes:XMLList = xml.property;

			for each (var propertyNode:XML in propertyNodes) {
				if (propertyNode.attribute(FILE_ATTRIBUTE_NAME).length() > 0) {
					var fileName:String = String(propertyNode.attribute(FILE_ATTRIBUTE_NAME)[0]);
					var isRequired:Boolean = (propertyNode.attribute(REQUIRED_ATTRIBUTE_NAME).length() > 0) ? (propertyNode.attribute(REQUIRED_ATTRIBUTE_NAME)[0] == true) : true;
					var preventCache:Boolean = (propertyNode.attribute(PREVENTCACHE_ATTRIBUTE_NAME).length() > 0) ? (propertyNode.attribute(PREVENTCACHE_ATTRIBUTE_NAME)[0] == true) : true;
					_propertyURIS[_propertyURIS.length] = new TextFileURI(fileName, isRequired, preventCache);
					delete xml.property[0];
				}

			}

			return xml;
		}
	}
}
