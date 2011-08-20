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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.customconfiguration {

	import org.as3commons.reflect.Method;
	import org.as3commons.reflect.Type;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.eventbus.process.EventHandlerProxy;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventHandlerCustomConfigurator implements ICustomConfigurator {

		private var _eventBusUserRegistry:IEventBusUserRegistry;
		private var _eventName:String;
		private var _eventHandlerMethodName:String;
		private var _eventClass:Class;
		private var _properties:Vector.<String>;
		private var _topics:Vector.<String>;
		private var _topicProperties:Vector.<String>;

		public function EventHandlerCustomConfigurator(eventBusUserRegistry:IEventBusUserRegistry, eventHandlerMethodName:String, eventName:String=null, eventClass:Class=null, properties:Vector.<String>=null, topics:Vector.<String>=null, topicProperties:Vector.<String>=null) {
			super();
			initEventHandlerCustomConfigurator(eventBusUserRegistry, eventHandlerMethodName, eventName, eventClass, properties, topics, topicProperties);
		}

		protected function initEventHandlerCustomConfigurator(eventBusUserRegistry:IEventBusUserRegistry, eventHandlerMethodName:String, eventName:String, eventClass:Class, properties:Vector.<String>, topics:Vector.<String>, topicProperties:Vector.<String>):void {
			_eventBusUserRegistry = eventBusUserRegistry;
			_eventHandlerMethodName = eventHandlerMethodName;
			_eventName = eventName;
			_eventClass = eventClass;
			_properties = properties;
			_topics = topics;
			_topicProperties = topicProperties;
		}


		public function execute(instance:*, objectDefinition:IObjectDefinition):void {
			var type:Type = Type.forClass(objectDefinition.clazz);
			var method:Method = type.getMethod(_eventHandlerMethodName);
			var proxy:EventHandlerProxy = new EventHandlerProxy(instance, method, _properties);
			var topic:String;
			if (((_topics == null) || (_topics.length == 0)) && ((_topicProperties == null) || (_topicProperties.length == 0))) {
				if (_eventName != null) {
					_eventBusUserRegistry.addEventListenerProxy(_eventName, proxy);
				}
				if (_eventClass != null) {
					_eventBusUserRegistry.addEventClassListenerProxy(_eventClass, proxy);
				}
			}
			if ((_topics != null) || (_topics.length > 0)) {
				for each (topic in _topics) {
					if (_eventName != null) {
						_eventBusUserRegistry.addEventListenerProxy(_eventName, proxy, false, topic);
					}
					if (_eventClass != null) {
						_eventBusUserRegistry.addEventClassListenerProxy(_eventClass, proxy, false, topic);
					}
				}
			}
			if ((_topicProperties != null) || (_topicProperties.length > 0)) {
				for each (topic in _topicProperties) {
					var topicInstance:* = instance[topic];
					if (_eventName != null) {
						_eventBusUserRegistry.addEventListenerProxy(_eventName, proxy, false, topicInstance);
					}
					if (_eventClass != null) {
						_eventBusUserRegistry.addEventClassListenerProxy(_eventClass, proxy, false, topicInstance);
					}
				}
			}
		}

	/*			<xs:attribute name="event-name" type="xs:String"/>
	<xs:attribute name="properties" type="xs:String" use="optional"/>
	<xs:attribute name="event-class" type="xs:String"/>
	<xs:attribute name="topics" type="xs:String" use="optional"/>
	<xsd:element name="topic-properties" type="xs:String" use="optional"/>*/

	}
}
