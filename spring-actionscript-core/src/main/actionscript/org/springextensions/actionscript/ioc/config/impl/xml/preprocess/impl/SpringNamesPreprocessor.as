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
	import org.springextensions.actionscript.ioc.Constants;
	import org.springextensions.actionscript.ioc.SpringConstants;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_objects;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.IXMLObjectDefinitionsPreprocessor;

	use namespace spring_actionscript_objects;

	/**
	 * Preprocesses an xml context and replaces all Spring specific names with
	 * their Spring Actionscript equivalent. This enables you to load in a Spring compliant
	 * context and parse it with Spring Actionscript.
	 *
	 * <p>
	 * <b>Author:</b> Christophe Herreman<br/>
	 * <b>Version:</b> $Revision: 21 $, $Date: 2008-11-01 22:58:42 +0100 (za, 01 nov 2008) $, $Author: dmurat $<br/>
	 * <b>Since:</b> 0.1
	 * </p>
	 */
	public class SpringNamesPreprocessor implements IXMLObjectDefinitionsPreprocessor {

		/**
		 * Creates a new <code>SpringNamesPreprocessor</code>
		 */
		public function SpringNamesPreprocessor() {
			super();
		}

		/**
		 * @inheritDoc
		 */
		public function preprocess(xml:XML):XML {
			xml = convertBeansDefinition(xml);
			xml = convertBeanDefinitions(xml);
			xml = convertBeanReferences(xml);
			return xml;
		}

		private function convertBeansDefinition(xml:XML):XML {
			if (SpringConstants.BEANS == xml.name().localName) {
				xml.setName(Constants.OBJECTS);
			}
			return xml;
		}

		private function convertBeanDefinitions(xml:XML):XML {
			var beans:XMLList = xml..bean;
			for each (var beanNode:XML in beans) {
				beanNode.setName(Constants.OBJECT);
			}
			return xml;
		}

		private function convertBeanReferences(xml:XML):XML {
			var nodes:XMLList = xml..ref.(attribute(SpringConstants.BEAN) != undefined);
			for each (var node:XML in nodes) {
				node.text()[0] = node.@bean;
				delete node.@bean;
			}
			return xml;
		}
	}
}
