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
package org.springextensions.actionscript.ioc.config.impl.xml.parser.impl.nodeparser {

	import flash.utils.Dictionary;

	import org.as3commons.lang.XMLUtils;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.impl.XMLObjectDefinitionsParser;

	/**
	 * Parses a dictionary node.
	 *
	 * @author Christophe Herreman
	 */
	public class DictionaryNodeParser extends AbstractNodeParser {

		/**
		 * Constructs the DictionaryNodeParser.
		 *
		 * @param xmlObjectDefinitionsParser  The definitions parser using this NodeParser
		 *
		 * @see org.springextensions.actionscript.ioc.factory.xml.parser.support.XMLObjectDefinitionsParser.#DICTIONARY_ELEMENT
		 * @see org.springextensions.actionscript.ioc.factory.xml.parser.support.XMLObjectDefinitionsParser.#MAP_ELEMENT
		 */
		public function DictionaryNodeParser(xmlObjectDefinitionsParser:IXMLObjectDefinitionsParser) {
			super(xmlObjectDefinitionsParser, XMLObjectDefinitionsParser.DICTIONARY_ELEMENT);
			addNodeNameAlias(XMLObjectDefinitionsParser.MAP_ELEMENT);
		}

		/**
		 * @inheritDoc
		 */
		override public function parse(node:XML):* {
			var result:Dictionary = new Dictionary();
			var keyAttribute:String = XMLObjectDefinitionsParser.KEY_ATTRIBUTE;
			var valueAttribute:String = XMLObjectDefinitionsParser.VALUE_ATTRIBUTE;

			for each (var n:XML in node.children()) {
				// convert the key and value attributes to childnodes
				n = XMLUtils.convertAttributeToNode(n, keyAttribute);
				n = XMLUtils.convertAttributeToNode(n, valueAttribute);
				// get the key and value from the childnodes
				var desc:XMLList = n.child(new QName(node.inScopeNamespaces()[0], keyAttribute));
				var key:* = xmlObjectDefinitionsParser.parsePropertyValue(desc[0]);
				desc = n.child(new QName(node.inScopeNamespaces()[0], valueAttribute));
				var value:* = xmlObjectDefinitionsParser.parsePropertyValue(desc[0]);
				result[key] = value;
			}

			return result;
		}
	}
}
