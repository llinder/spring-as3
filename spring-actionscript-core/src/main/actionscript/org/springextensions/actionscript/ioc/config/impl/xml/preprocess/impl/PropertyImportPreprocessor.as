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
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_objects;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.IXMLObjectDefinitionsPreprocessor;
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
		private static const FALSE_VALUE:String = "false";
		private var _configurerClassName:String;

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		public function PropertyImportPreprocessor() {
			super();
			propertyImportPreprocessorInit();
		}

		protected function propertyImportPreprocessorInit():void {
			if (Environment.isFlash) {
				_configurerClassName = "org.springextensions.actionscript.ioc.factory.config.PropertyPlaceholderConfigurer";
			} else {
				_configurerClassName = "org.springextensions.actionscript.ioc.factory.config.flex.FlexPropertyPlaceholderConfigurer";
			}
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
					var node:XML = <object class={_configurerClassName}>
							<property name="location" value={propertyNode.attribute(FILE_ATTRIBUTE_NAME)[0]}/>
						</object>;

					// "required" attribute
					if (propertyNode.attribute(REQUIRED_ATTRIBUTE_NAME).length() > 0) {
						var notRequired:Boolean = (propertyNode.attribute(REQUIRED_ATTRIBUTE_NAME)[0] == FALSE_VALUE);
						if (notRequired) {
							node.appendChild(<property name="ignoreResourceNotFound" value="true"/>);
						}
					}

					xml.appendChild(node);
					delete xml.property[0];
				}

			}

			return xml;
		}
	}
}
