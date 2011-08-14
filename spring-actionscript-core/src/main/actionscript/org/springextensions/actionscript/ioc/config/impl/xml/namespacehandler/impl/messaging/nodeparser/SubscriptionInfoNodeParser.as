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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.messaging.nodeparser {
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.ParsingUtils;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;

	/**
	 * @docref xml-schema-based-configuration.html#the_messaging_schema
	 * @author Christophe Herreman
	 */
	public class SubscriptionInfoNodeParser extends AbstractObjectDefinitionParser {

		public static const MAX_FREQUENCY_ATTR:String = "max-frequency";

		public static const SELECTOR_ATTR:String = "selector";

		public static const SUBTOPIC_ATTR:String = "subtopic";

		/**
		 * Creates a new <code>SubscriptionInfoNodeParser</code> instance.
		 */
		public function SubscriptionInfoNodeParser() {
		}

		override protected function parseInternal(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			var result:IObjectDefinition = new ObjectDefinition("");
			mapProperties(result, node);
			return result;
		}

		protected function mapProperties(objectDefinition:IObjectDefinition, node:XML):void {
			ParsingUtils.mapProperties(objectDefinition, node, MAX_FREQUENCY_ATTR, SELECTOR_ATTR, SUBTOPIC_ATTR);
		}

	}
}
