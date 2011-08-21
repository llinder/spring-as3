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
	import org.as3commons.eventbus.IEventBus;
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

		/**
		 * Creates a new <code>EventHandlerCustomConfigurator</code>
		 * @param eventBusUserRegistry
		 * @param eventHandlerMethodName
		 * @param eventName
		 * @param eventClass
		 * @param properties
		 * @param topics
		 * @param topicProperties
		 */
		public function EventHandlerCustomConfigurator(eventBusUserRegistry:IEventBusUserRegistry, eventHandlerMethodName:String, eventName:String=null, eventClass:Class=null, properties:Vector.<String>=null, topics:Vector.<String>=null, topicProperties:Vector.<String>=null) {
			super();
			initEventHandlerCustomConfigurator(eventBusUserRegistry, eventHandlerMethodName, eventName, eventClass, properties, topics, topicProperties);
		}

		private var _eventBusUserRegistry:IEventBusUserRegistry;
		private var _eventClass:Class;
		private var _eventHandlerMethodName:String;
		private var _eventName:String;
		private var _properties:Vector.<String>;
		private var _topicProperties:Vector.<String>;
		private var _topics:Vector.<String>;

		/**
		 *
		 */
		public function get eventBusUserRegistry():IEventBusUserRegistry {
			return _eventBusUserRegistry;
		}

		/**
		 *
		 */
		public function get eventClass():Class {
			return _eventClass;
		}

		/**
		 *
		 */
		public function get eventHandlerMethodName():String {
			return _eventHandlerMethodName;
		}

		/**
		 *
		 */
		public function get eventName():String {
			return _eventName;
		}

		/**
		 *
		 */
		public function get properties():Vector.<String> {
			return _properties;
		}

		/**
		 *
		 */
		public function get topicProperties():Vector.<String> {
			return _topicProperties;
		}

		/**
		 *
		 */
		public function get topics():Vector.<String> {
			return _topics;
		}

		/**
		 *
		 * @param instance
		 * @param objectDefinition
		 */
		public function execute(instance:*, objectDefinition:IObjectDefinition):void {
			var type:Type = Type.forClass(objectDefinition.clazz);
			var method:Method = type.getMethod(_eventHandlerMethodName);
			var proxy:EventHandlerProxy = new EventHandlerProxy(instance, method, _properties);
			var topic:String;
			if (((_topics == null) || (_topics.length == 0)) && ((_topicProperties == null) || (_topicProperties.length == 0))) {
				addEventBusListener(_eventBusUserRegistry, _eventName, _eventClass, proxy);
			}
			for each (topic in _topics) {
				addEventBusListener(_eventBusUserRegistry, _eventName, _eventClass, proxy, topic);
			}
			for each (topic in _topicProperties) {
				var topicInstance:* = instance[topic];
				addEventBusListener(_eventBusUserRegistry, _eventName, _eventClass, proxy, topicInstance);
			}
		}

		/**
		 *
		 * @param registry
		 * @param name
		 * @param clazz
		 * @param proxy
		 * @param topic
		 */
		protected function addEventBusListener(registry:IEventBusUserRegistry, name:String, clazz:Class, proxy:EventHandlerProxy, topic:*=null):void {
			if (name != null) {
				registry.addEventListenerProxy(name, proxy, false, topic);
			}
			if (clazz != null) {
				registry.addEventClassListenerProxy(clazz, proxy, false, topic);
			}
		}

		/**
		 *
		 * @param eventBusUserRegistry
		 * @param eventHandlerMethodName
		 * @param eventName
		 * @param eventClass
		 * @param properties
		 * @param topics
		 * @param topicProperties
		 */
		protected function initEventHandlerCustomConfigurator(eventBusUserRegistry:IEventBusUserRegistry, eventHandlerMethodName:String, eventName:String, eventClass:Class, properties:Vector.<String>, topics:Vector.<String>, topicProperties:Vector.<String>):void {
			_eventBusUserRegistry = eventBusUserRegistry;
			_eventHandlerMethodName = eventHandlerMethodName;
			_eventName = eventName;
			_eventClass = eventClass;
			_properties = properties;
			_topics = topics;
			_topicProperties = topicProperties;
		}
	}
}
