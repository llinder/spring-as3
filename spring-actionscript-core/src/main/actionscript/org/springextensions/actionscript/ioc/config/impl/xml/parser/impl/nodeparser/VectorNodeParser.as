/*
 * Copyright 2007-2008 the original author or authors.
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

	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;

	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.StringUtils;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.impl.XMLObjectDefinitionsParser;

	/**
	 * @author Roland Zwaga
	 */
	public class VectorNodeParser extends AbstractNodeParser {

		private static const TYPE_ATTRIBUTE_NAME:String = "type";
		private static const AS3VEC_VECTOR_CLASS_TEMPLATE:String = "__AS3__.vec.Vector.<{0}>";

		private var _applicationDomain:ApplicationDomain;

		/**
		 * Creates a new <code>VectorNodeParser</code> instance.
		 * @param xmlObjectDefinitionsParser
		 *
		 */
		public function VectorNodeParser(xmlObjectDefinitionsParser:IXMLObjectDefinitionsParser, applicationDomain:ApplicationDomain) {
			super(xmlObjectDefinitionsParser, XMLObjectDefinitionsParser.VECTOR_ELEMENT);
			_applicationDomain = applicationDomain;
		}

		/**
		 * @inheritDoc
		 */
		override public function parse(node:XML):Object {
			var type:String = node.attribute(TYPE_ATTRIBUTE_NAME).toString();
			var className:String = StringUtils.substitute(AS3VEC_VECTOR_CLASS_TEMPLATE, type);
			var cls:Class = ClassUtils.forName(className, _applicationDomain);
			var result:Array = [cls];

			for each (var n:XML in node.children()) {
				result[result.length] = xmlObjectDefinitionsParser.parsePropertyValue(n);
			}

			return result;
		}

	}
}
