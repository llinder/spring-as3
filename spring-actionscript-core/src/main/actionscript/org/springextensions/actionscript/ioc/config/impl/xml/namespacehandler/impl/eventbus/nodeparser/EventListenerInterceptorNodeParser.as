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

	import flash.system.ApplicationDomain;

	import org.as3commons.eventbus.IEventListenerInterceptor;
	import org.as3commons.lang.ClassUtils;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.customconfiguration.EventListenerInterceptorCustomConfigurator;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_eventbus;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventListenerInterceptorNodeParser extends AbstractEventBusNodeParser {

		/**
		 * Creates a new <code>EventListenerInterceptorNodeParser</code> instance.
		 * @param objectDefinitionRegistry
		 * @param eventBusUserRegistry
		 */
		public function EventListenerInterceptorNodeParser(objectDefinitionRegistry:IObjectDefinitionRegistry, eventBusUserRegistry:IEventBusUserRegistry, applicationDomain:ApplicationDomain) {
			super(objectDefinitionRegistry, eventBusUserRegistry, applicationDomain);
		}

		/**
		 *
		 * @param node
		 * @param context
		 * @return
		 */
		override public function parse(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			var ref:String = String(node.attribute(INSTANCE_ATTRIBUTE_NAME)[0]);
			if (objectDefinitionRegistry.containsObjectDefinition(ref)) {
				var objectDefinition:IObjectDefinition = objectDefinitionRegistry.getObjectDefinition(ref);
				if (!ClassUtils.isImplementationOf(objectDefinition.clazz, IEventListenerInterceptor)) {
					throw new Error("Object definition must describe a class that implements IEventListenerInterceptor");
				}
				objectDefinition.customConfiguration ||= new Vector.<ICustomConfigurator>();
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
			var QN:QName = new QName(spring_actionscript_eventbus, INTERCEPTION_CONFIGURATION_ATTRIBUTE_NAME);
			var list:XMLList = node.descendants(QN);
			for each (var child:XML in list) {
				createEventInterceptorConfiguration(customConfiguration, child);
			}
		}

		/**
		 *
		 * @param customConfiguration
		 * @param child
		 */
		protected function createEventInterceptorConfiguration(customConfiguration:Vector.<ICustomConfigurator>, child:XML):void {
			if (child.attribute(EVENT_NAME_ATTRIBUTE_NAME).length() > 0) {
				var eventName:String = String(child.attribute(EVENT_NAME_ATTRIBUTE_NAME)[0]);
			}
			if (child.attribute(EVENT_CLASS_ATTRIBUTE_NAME).length() > 0) {
				var eventClass:Class = ClassUtils.forName(String(child.attribute(EVENT_CLASS_ATTRIBUTE_NAME)[0]), applicationDomain);
			}
			var topics:Vector.<String> = commaSeparatedAttributeNameToStringVector(child, TOPICS_ATTRIBUTE_NAME);
			var topicProperties:Vector.<String> = commaSeparatedAttributeNameToStringVector(child, TOPIC_PROPERTIES_ATTRIBUTE_NAME);
			var config:EventListenerInterceptorCustomConfigurator = new EventListenerInterceptorCustomConfigurator(eventBusUserRegistry, eventName, eventClass, topics, topicProperties);
			customConfiguration[customConfiguration.length] = config;
		}
	}
}
