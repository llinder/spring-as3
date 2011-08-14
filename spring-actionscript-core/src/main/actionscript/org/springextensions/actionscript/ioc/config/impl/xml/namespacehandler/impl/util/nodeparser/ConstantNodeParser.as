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
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.ParsingUtils;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.factory.impl.FieldRetrievingFactoryObject;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;

	/**
	 *
	 * @docref xml-schema-based-configuration.html#the_util_schema
	 * @author Christophe Herreman
	 */
	public class ConstantNodeParser extends AbstractObjectDefinitionParser {

		public static const STATIC_FIELD:String = "static-field";
		public static const TARGET_CLASS:String = "target-class";
		public static const TARGET_OBJECT:String = "target-object";
		public static const TARGET_FIELD:String = "target-field";

		/**
		 * Creates a new <code>ConstantNodeParser</code> instance
		 */
		public function ConstantNodeParser() {
			super();
		}

		/**
		 * @inheritDoc
		 */
		override protected function parseInternal(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			var result:IObjectDefinition = new ObjectDefinition(ClassUtils.getFullyQualifiedName(FieldRetrievingFactoryObject, true));

			ParsingUtils.mapProperties(result, node, STATIC_FIELD);
			ParsingUtils.mapProperties(result, node, TARGET_CLASS);
			ParsingUtils.mapProperties(result, node, TARGET_OBJECT);
			ParsingUtils.mapProperties(result, node, TARGET_FIELD);

			return result;
		}

	}
}
