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

	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinitionBuilder;
	import org.springextensions.actionscript.stage.DefaultAutowiringStageProcessor;


	public class AutowiringStageProcessorNodeParser extends StageProcessorNodeParser {

		public function AutowiringStageProcessorNodeParser() {
			super();
		}

		override protected function parseInternal(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			var result:ObjectDefinitionBuilder = ObjectDefinitionBuilder.objectDefinitionForClass(DefaultAutowiringStageProcessor);

			var objectName:String = resolveID(node, result.objectDefinition, context);

			if (node.attribute(OBJECT_SELECTOR_ATTR).length() > 0) {
				var objectSelectorName:String = String(node.attribute(OBJECT_SELECTOR_ATTR)[0]);
				result.objectDefinition.customConfiguration = objectSelectorName
			}

			return result.objectDefinition;
		}

	}
}
