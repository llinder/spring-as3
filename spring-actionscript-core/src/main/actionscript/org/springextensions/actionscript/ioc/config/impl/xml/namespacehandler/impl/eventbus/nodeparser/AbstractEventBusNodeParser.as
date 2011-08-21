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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.nodeparser {
	import flash.errors.IllegalOperationError;

	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.IObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_eventbus;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class AbstractEventBusNodeParser implements IObjectDefinitionParser {

		public static const INSTANCE_ATTRIBUTE_NAME:String = "instance";
		public static const EVENT_NAMES_ATTRIBUTE_NAME:String = "event-names";
		public static const EVENT_NAME_ATTRIBUTE_NAME:String = "event-name";
		public static const METHOD_NAME_ATTRIBUTE_NAME:String = "method-name";
		public static const EVENT_CLASS_ATTRIBUTE_NAME:String = "event-class";
		public static const TOPICS_ATTRIBUTE_NAME:String = "topics";
		public static const TOPIC_PROPERTIES_ATTRIBUTE_NAME:String = "topic-properties";
		public static const COMMA:String = ',';
		public static const SPACE:String = ' ';
		public static const EMPTY:String = '';

		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;
		private var _eventBusUserRegistry:IEventBusUserRegistry;

		use namespace spring_actionscript_eventbus;

		/**
		 * Creates a new <code>AbstractEventBusNodeParser</code> instance.
		 * @param objectDefinitionRegistry
		 * @param eventBusUserRegistry
		 */
		public function AbstractEventBusNodeParser(objectDefinitionRegistry:IObjectDefinitionRegistry, eventBusUserRegistry:IEventBusUserRegistry) {
			super();
			init(objectDefinitionRegistry, eventBusUserRegistry);
		}

		/**
		 * Initializes the current <code>AbstractEventBusNodeParser</code>.
		 * @param objectDefinitionRegistry
		 * @param eventBusUserRegistry
		 */
		protected function init(objectDefinitionRegistry:IObjectDefinitionRegistry, eventBusUserRegistry:IEventBusUserRegistry):void {
			_objectDefinitionRegistry = objectDefinitionRegistry;
			_eventBusUserRegistry = eventBusUserRegistry;
		}

		/**
		 *
		 */
		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectDefinitionRegistry;
		}

		/**
		 *
		 * @return
		 */
		public function get eventBusUserRegistry():IEventBusUserRegistry {
			return _eventBusUserRegistry;
		}

		/**
		 *
		 * @param node
		 * @param context
		 * @return
		 */
		public function parse(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			throw new IllegalOperationError("Not implemented in base class");
		}

		/**
		 *
		 * @param node
		 * @return
		 */
		protected function getPropertyNames(node:XML):Array {
			if (node.attribute(EVENT_NAMES_ATTRIBUTE_NAME).length() > 0) {
				return String(node.attribute(EVENT_NAMES_ATTRIBUTE_NAME)[0]).split(SPACE).join(EMPTY).split(COMMA);
			}
			return null;
		}

		/**
		 *
		 * @param node
		 * @param attributeName
		 * @return
		 */
		protected function commaSeparatedAttributeNameToStringVector(node:XML, attributeName:String):Vector.<String> {
			if (node.attribute(attributeName).length() > 0) {
				var parts:Array = String(node.attribute(attributeName)[0]).split(SPACE).join(EMPTY).split(COMMA);
				var result:Vector.<String> = new Vector.<String>();
				for each (var name:String in parts) {
					result[result.length] = name;
				}
				return result;
			}
			return null;
		}

	}
}
