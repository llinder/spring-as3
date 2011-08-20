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
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.IObjectDefinitionParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.customconfiguration.RouteEventsCustomConfigurator;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventRouterNodeParser implements IObjectDefinitionParser {

		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;

		public function EventRouterNodeParser(objectDefinitionRegistry:IObjectDefinitionRegistry) {
			super();
			initEventRouterNodeParser(objectDefinitionRegistry);
		}

		protected function initEventRouterNodeParser(objectDefinitionRegistry:IObjectDefinitionRegistry):void {
			Assert.notNull(objectDefinitionRegistry, "objectDefinitionRegistry must not be null");
			_objectDefinitionRegistry = objectDefinitionRegistry;
		}


		public function parse(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			var ref:String = String(node.attribute("instance")[0]);
			if (_objectDefinitionRegistry.containsObjectDefinition(ref)) {
				var objectDefinition:IObjectDefinition = _objectDefinitionRegistry.getObjectDefinition(ref);
				objectDefinition.customConfiguration ||= new Vector.<ICustomConfigurator>;
				var names:Vector.<String> = getPropertyNames(node);
				var configurator:RouteEventsCustomConfigurator = new RouteEventsCustomConfigurator(names);
				objectDefinition.customConfiguration[objectDefinition.customConfiguration.length] = configurator;
			}
			return null;
		}

		protected function getPropertyNames(node:XML):Vector.<String> {
			if (node.attribute("event-names").length() > 0) {
				var parts:Array = String(node.attribute("event-names")[0]).split(' ').join('').split(',');
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
