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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus {
	import flash.system.ApplicationDomain;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistryAware;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractNamespaceHandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.nodeparser.EventHandlerNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.nodeparser.EventInterceptorNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.nodeparser.EventListenerInterceptorNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.nodeparser.EventRouterNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser.NullReturningNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_eventbus;
	import org.springextensions.actionscript.ioc.factory.IInitializingObject;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistryAware;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventBusNamespacehandler extends AbstractNamespaceHandler implements IObjectDefinitionRegistryAware, IEventBusUserRegistryAware, IApplicationDomainAware, IInitializingObject {
		public static const EVENT_HANDLER_ELEMENT_NAME:String = "event-handler";
		public static const EVENT_HANDLER_METHOD_ELEMENT_NAME:String = "event-handler-method";
		public static const EVENT_INTERCEPTOR_FIELD_NAME:String = "event-interceptor";
		public static const EVENT_LISTENER_INTERCEPTOR_FIELD_NAME:String = "event-listener-interceptor";

		public static const EVENT_ROUTER_ELEMENT_NAME:String = "event-router";
		public static const ROUTING_CONFIGURATION_ELEMENT_NAME:String = "routing-configuration";

		/**
		 * Creates a new <code>EventBusNamespacehandler</code> instance.
		 * @param objectDefinitionRegistry
		 */
		public function EventBusNamespacehandler() {
			super(spring_actionscript_eventbus);
		}

		private var _applicationDomain:ApplicationDomain;

		private var _eventBusUserRegistry:IEventBusUserRegistry;
		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;

		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}

		public function get eventBusUserRegistry():IEventBusUserRegistry {
			return _eventBusUserRegistry;
		}

		public function set eventBusUserRegistry(value:IEventBusUserRegistry):void {
			_eventBusUserRegistry = value;
		}

		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectDefinitionRegistry;
		}

		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_objectDefinitionRegistry = value;
		}

		public function afterPropertiesSet():void {
			registerObjectDefinitionParser(EVENT_ROUTER_ELEMENT_NAME, new EventRouterNodeParser(_objectDefinitionRegistry, eventBusUserRegistry, _applicationDomain));
			registerObjectDefinitionParser(EVENT_HANDLER_ELEMENT_NAME, new EventHandlerNodeParser(_objectDefinitionRegistry, eventBusUserRegistry, _applicationDomain));
			registerObjectDefinitionParser(EVENT_HANDLER_METHOD_ELEMENT_NAME, new NullReturningNodeParser());
			registerObjectDefinitionParser(EVENT_INTERCEPTOR_FIELD_NAME, new EventInterceptorNodeParser(_objectDefinitionRegistry, eventBusUserRegistry, _applicationDomain));
			registerObjectDefinitionParser(EVENT_LISTENER_INTERCEPTOR_FIELD_NAME, new EventListenerInterceptorNodeParser(_objectDefinitionRegistry, eventBusUserRegistry, _applicationDomain));
			registerObjectDefinitionParser(ROUTING_CONFIGURATION_ELEMENT_NAME, new NullReturningNodeParser());
		}
	}
}
