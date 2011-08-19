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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.stageprocessing.nodeparser {

	import org.as3commons.lang.ClassUtils;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.ParsingUtils;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinitionBuilder;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class StageProcessorNodeParser extends AbstractObjectDefinitionParser {

		/** The object-selector attribute */
		public static const OBJECT_SELECTOR_ATTR:String = "object-selector";

		/**
		 * Creates a new <code>StageProcessorNodeParser</code> instance.
		 */
		public function StageProcessorNodeParser() {
			super();
		}

		/**
		 * @inheritDoc
		 */
		override protected function parseInternal(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			var cls:Class = ClassUtils.forName(String(node.attribute("class")[0]));
			var result:ObjectDefinitionBuilder = ObjectDefinitionBuilder.objectDefinitionForClass(cls);

			var objectName:String = resolveID(node, result.objectDefinition, context);
			context.registerObjectDefinition(objectName, result.objectDefinition);

			if (node.attribute(OBJECT_SELECTOR_ATTR).length() > 0) {
				var objectSelectorName:String = String(node.attribute(OBJECT_SELECTOR_ATTR)[0]);
				result.objectDefinition.customConfiguration = objectSelectorName
			}

			return result.objectDefinition;
		}
	}
}
