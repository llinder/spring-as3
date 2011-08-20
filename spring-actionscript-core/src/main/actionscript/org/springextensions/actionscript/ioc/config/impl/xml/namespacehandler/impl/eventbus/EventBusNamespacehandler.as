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

	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractNamespaceHandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.nodeparser.EventRouterNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_eventbus;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.IXMLObjectDefinitionsPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.EventBusElementsPreprocessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 *
	 */
	public class EventBusNamespacehandler extends AbstractNamespaceHandler implements IXMLObjectDefinitionsPreprocessor {

		private static const EVENT_ROUTER_ELEMENT_NAME:String = "event-router";
		private static const EVENT_HANDLER_ELEMENT_NAME:String = "event-handler";
		private static const EVENT_HANDLER_METHOD_ELEMENT_NAME:String = "event-handler-method";

		private var _preprocessor:EventBusElementsPreprocessor;

		public function EventBusNamespacehandler(objectDefinitionRegistry:IObjectDefinitionRegistry) {
			super(spring_actionscript_eventbus);
			initEventBusNamespacehandler(objectDefinitionRegistry);
		}

		protected function initEventBusNamespacehandler(objectDefinitionRegistry:IObjectDefinitionRegistry):void {
			_preprocessor = new EventBusElementsPreprocessor();
			registerObjectDefinitionParser(EVENT_ROUTER_ELEMENT_NAME, new EventRouterNodeParser(objectDefinitionRegistry));
			registerObjectDefinitionParser(EVENT_HANDLER_ELEMENT_NAME, null);
			registerObjectDefinitionParser(EVENT_HANDLER_METHOD_ELEMENT_NAME, null);
		}

		public function preprocess(xml:XML):XML {
			return _preprocessor.preprocess(xml);
		}
	}
}
