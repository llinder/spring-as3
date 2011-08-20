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
	import org.as3commons.lang.Assert;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.IObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.EventBusNamespacehandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.customconfiguration.RouteEventsCustomConfigurator;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventRouterNodeParser extends AbstractEventBusNodeParser {

		/**
		 * Creates a new <code>EventRouterNodeParser</code> instance.
		 * @param objectDefinitionRegistry
		 * @param eventBusUserRegistry
		 */
		public function EventRouterNodeParser(objectDefinitionRegistry:IObjectDefinitionRegistry, eventBusUserRegistry:IEventBusUserRegistry) {
			super(objectDefinitionRegistry, eventBusUserRegistry);
		}

		/**
		 * @inheritDoc
		 */
		override public function parse(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			var ref:String = String(node.attribute(INSTANCE_ATTRIBUTE_NAME)[0]);
			if (objectDefinitionRegistry.containsObjectDefinition(ref)) {
				var objectDefinition:IObjectDefinition = objectDefinitionRegistry.getObjectDefinition(ref);
				objectDefinition.customConfiguration ||= new Vector.<ICustomConfigurator>;
				createConfigurations(objectDefinition.customConfiguration, node);
			}
			return null;
		}

		/**
		 *
		 * @param customConfiguration
		 * @param node
		 */
		protected function createConfigurations(customConfiguration:Vector.<ICustomConfigurator>, node:XML):void {
			for each (var child:XML in node.descendants(EventBusNamespacehandler.ROUTING_CONFIGURATION_ELEMENT_NAME)) {
				var names:Array = getPropertyNames(child);
				var topics:Vector.<String> = commaSeparatedAttributeNameToStringVector(child, TOPICS_ATTRIBUTE_NAME);
				var topicProperties:Vector.<String> = commaSeparatedAttributeNameToStringVector(child, TOPIC_PROPERTIES_ATTRIBUTE_NAME);
				var configurator:RouteEventsCustomConfigurator = new RouteEventsCustomConfigurator(eventBusUserRegistry, names, topics, topicProperties);
				customConfiguration[customConfiguration.length] = configurator;
			}
		}

	}
}
