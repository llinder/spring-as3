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

	import flash.events.IEventDispatcher;

	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;


	public class RouteEventsCustomConfigurator implements ICustomConfigurator {

		private var _eventNames:Array;
		private var _topics:Vector.<String>;
		private var _topicProperties:Vector.<String>;
		private var _eventBusUserRegistry:IEventBusUserRegistry;

		public function RouteEventsCustomConfigurator(eventBusUserRegistry:IEventBusUserRegistry, eventNames:Array=null, topics:Vector.<String>=null, topicProperties:Vector.<String>=null) {
			super();
			initRouteEventsCustomConfigurator(eventNames, topics, topicProperties, eventBusUserRegistry);
		}

		protected function initRouteEventsCustomConfigurator(eventNames:Array, topics:Vector.<String>, topicProperties:Vector.<String>, eventBusUserRegistry:IEventBusUserRegistry):void {
			_eventNames = eventNames;
			_topics = topics;
			_topicProperties = topicProperties;
			_eventBusUserRegistry = eventBusUserRegistry;
		}

		public function execute(instance:*, objectDefinition:IObjectDefinition):void {
			var resolvedTopics:Array;
			var topic:String;
			for each (topic in _topics) {
				resolvedTopics ||= [];
				resolvedTopics[resolvedTopics.length] = topic;
			}
			for each (topic in _topicProperties) {
				resolvedTopics ||= [];
				resolvedTopics[resolvedTopics.length] = instance[topic];
			}
			_eventBusUserRegistry.addEventListeners(IEventDispatcher(instance), _eventNames, resolvedTopics);
		}
	}
}
