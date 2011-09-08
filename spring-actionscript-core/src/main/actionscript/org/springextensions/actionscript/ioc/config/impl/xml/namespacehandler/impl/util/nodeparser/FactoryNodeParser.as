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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.util.nodeparser {
	import org.as3commons.lang.ClassUtils;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.IObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.util.customconfiguration.FactoryObjectCustomConfigurator;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinitionBuilder;



	/**
	 *
	 * @author Roland Zwaga
	 */
	public class FactoryNodeParser extends AbstractObjectDefinitionParser {

		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;

		/**
		 * Creates a new <code>FactoryNodeParser</code> instance.
		 */
		public function FactoryNodeParser(objectDefinitionRegistry:IObjectDefinitionRegistry) {
			super();
			_objectDefinitionRegistry = objectDefinitionRegistry;
		}

		override protected function parseInternal(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			var cls:Class = ClassUtils.forName(String(node.attribute("class")[0]));
			var result:ObjectDefinitionBuilder = ObjectDefinitionBuilder.objectDefinitionForClass(cls);

			context.parseConstructorArguments(result.objectDefinition, node);
			context.parseMethodInvocations(result.objectDefinition, node);
			context.parseProperties(result.objectDefinition, node);

			var objectName:String = resolveID(node, result.objectDefinition, context);
			context.registerObjectDefinition(objectName, result.objectDefinition);

			result.objectDefinition.customConfiguration = new FactoryObjectCustomConfigurator(result.objectDefinition.factoryMethod);
			result.objectDefinition.factoryMethod = "";
			result.objectDefinition.factoryObjectName = "";

			return result.objectDefinition;
		}
	}
}
