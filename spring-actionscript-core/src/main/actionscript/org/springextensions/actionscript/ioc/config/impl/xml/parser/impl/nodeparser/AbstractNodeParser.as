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

	import flash.errors.IllegalOperationError;

	import org.springextensions.actionscript.ioc.config.impl.xml.parser.INodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;

	/**
	 * Abstract base class for node parsers.
	 *
	 * <p>
	 * <b>Authors:</b> Christophe Herreman, Erik Westra<br/>
	 * <b>Version:</b> $Revision: 21 $, $Date: 2008-11-01 22:58:42 +0100 (za, 01 nov 2008) $, $Author: dmurat $<br/>
	 * <b>Since:</b> 0.1
	 * </p>
	 */
	public class AbstractNodeParser implements INodeParser {
		private static const PARSE_IS_ABSTRACT_ERROR:String = "parse() is abstract";

		/**
		 * The xmlObjectDefinitionsParser using this NodeParser
		 */
		protected var xmlObjectDefinitionsParser:IXMLObjectDefinitionsParser;

		/**
		 * An array containing the compatible node names.
		 */
		protected var nodeNames:Vector.<String>;

		/**
		 * This class should not be instantiated directly. Create a subclass that implements the parse method.
		 *
		 * @param xmlObjectDefinitionsParser  The definitions parser using this NodeParser
		 * @param nodeName            The name of the node this parser should react to
		 */
		public function AbstractNodeParser(xmlObjectDefinitionsParser:IXMLObjectDefinitionsParser, nodeName:String) {
			super();
			initAbstractNodeParser(xmlObjectDefinitionsParser, nodeName);
		}

		/**
		 * Initializes the current <code>AbstractNodeParser</code>.
		 * @param xmlObjectDefinitionsParser
		 * @param nodeName
		 */
		protected function initAbstractNodeParser(xmlObjectDefinitionsParser:IXMLObjectDefinitionsParser, nodeName:String):void {
			this.xmlObjectDefinitionsParser = xmlObjectDefinitionsParser;
			nodeNames = new Vector.<String>();
			nodeNames[nodeNames.length] = nodeName;
		}

		/**
		 * @inheritDoc
		 */
		public function addNodeNameAlias(alias:String):void {
			nodeNames.push(alias);
		}

		/**
		 * @inheritDoc
		 */
		public function canParse(node:XML):Boolean {
			return (nodeNames.indexOf(node.name().localName.toLowerCase()) != -1);
		}

		/**
		 * @inheritDoc
		 */
		public function getNodeNames():Vector.<String> {
			return this.nodeNames;
		}

		/**
		 * This is an abstract method and should be overridden in a subclass.
		 *
		 * @inheritDoc
		 */
		public function parse(node:XML):* {
			throw new IllegalOperationError(PARSE_IS_ABSTRACT_ERROR);
		}
	}
}
