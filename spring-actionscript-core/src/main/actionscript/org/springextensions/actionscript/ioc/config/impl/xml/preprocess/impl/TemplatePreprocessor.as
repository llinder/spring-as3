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

	use namespace spring_actionscript_objects;

	/**
	 * The <code>TemplatePreprocessor</code> is used to apply all templates
	 * to the xml context. The parser nor the container should be aware of
	 * templates.
	 *
	 * @author Christophe Herreman
	 * @docref container-documentation.html#object_definition_inheritance
	 */
	public class TemplatePreprocessor implements IXMLObjectDefinitionsPreprocessor {

		private static const TEMPLATE_BEGIN:String = "${";
		private static const TEMPLATE_END:String = "}";
		private static const TEMPLATE_ATTRIBUTE_NAME:String = "template";
		private static const ID_ATTRIBUTE_NAME:String = "id";
		private static const OBJECT_ELEMENT_NAME:String = "object";
		private static const CLASS_ATTRIBUTE_NAME:String = "class";

		/**
		 * Creates a new <code>TemplatePreprocessor</code>
		 */
		public function TemplatePreprocessor() {
			super();
		}

		/**
		 * @inheritDoc
		 */
		public function preprocess(xml:XML):XML {
			// the nodes that use a template
			var nodes:XMLList = xml..*.(attribute(TEMPLATE_ATTRIBUTE_NAME) != undefined);

			// loop through each node that uses a template and apply the template
			for each (var node:XML in nodes) {
				var template:XML = xml.template.(attribute(ID_ATTRIBUTE_NAME) == node.@template)[0];
				var templateText:String = template.children()[0].toXMLString();

				// replace all parameters
				for each (var param:XML in node.param) {
					var key:String = TEMPLATE_BEGIN + param.@name + TEMPLATE_END;
					// replace the key with the value of the parameter
					templateText = templateText.split(key).join(param.value.toString());
					// remove the param node from the main node
					delete node.param[0];
				}

				// fill the object with the result of the template
				// if the node is an object node, we fill it
				// if the node is a property node, we append it
				var newNodeXML:XML = new XML(templateText);
				var nodeName:QName = node.name() as QName;

				if (nodeName.localName == OBJECT_ELEMENT_NAME) {
					node.@[CLASS_ATTRIBUTE_NAME] = newNodeXML.attribute(CLASS_ATTRIBUTE_NAME).toString();
					for each (var n:XML in newNodeXML.children()) {
						node.appendChild(n);
					}
				} else {
					node.text()[0] = newNodeXML;
				}

				// remove the template attribute
				delete node.@template;
			}

			return xml;
		}
	}
}
