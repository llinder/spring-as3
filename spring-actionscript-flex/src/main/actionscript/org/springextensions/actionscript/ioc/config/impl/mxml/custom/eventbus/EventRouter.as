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
package org.springextensions.actionscript.ioc.config.impl.mxml.custom.eventbus {

	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistryAware;
	import org.springextensions.actionscript.ioc.config.impl.mxml.custom.AbstractCustomObjectDefinitionComponent;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.customconfiguration.RouteEventsCustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.util.ContextUtils;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventRouter extends AbstractEventBusComponent {

		/**
		 * Creates a new <code>EventRouter</code> instance.
		 */
		public function EventRouter() {
			super();
		}

		override public function execute(applicationContext:IApplicationContext, objectDefinitions:Object):void {
			if (applicationContext is IEventBusUserRegistryAware) {
				eventBusUserRegistry = (applicationContext as IEventBusUserRegistryAware).eventBusUserRegistry;
			}
			var customConfiguration:Vector.<ICustomConfigurator> = ContextUtils.getCustomConfigurationForObjectName(instance, applicationContext.objectDefinitionRegistry);
			for each (var field:Object in childContent) {
				if (field is EventRouterConfiguration) {
					var er:EventRouterConfiguration = field as EventRouterConfiguration;
					var eventNames:Vector.<String> = AbstractCustomObjectDefinitionComponent.commaSeparatedPropertyValueToStringVector(er.eventNames);
					var topics:Vector.<String> = AbstractCustomObjectDefinitionComponent.commaSeparatedPropertyValueToStringVector(er.topics);
					var topicProperties:Vector.<String> = AbstractCustomObjectDefinitionComponent.commaSeparatedPropertyValueToStringVector(er.topicProperties);
					var configurator:RouteEventsCustomConfigurator = new RouteEventsCustomConfigurator(eventBusUserRegistry, eventNames, topics, topicProperties);
					customConfiguration[customConfiguration.length] = configurator;
				}
			}
			applicationContext.objectDefinitionRegistry.registerCustomConfiguration(instance, customConfiguration);
		}

	}
}
