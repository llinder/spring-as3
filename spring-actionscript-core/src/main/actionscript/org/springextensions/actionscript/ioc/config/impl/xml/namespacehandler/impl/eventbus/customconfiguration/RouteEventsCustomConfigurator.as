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

	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;


	public class RouteEventsCustomConfigurator implements ICustomConfigurator {

		private var _data:*;

		public function RouteEventsCustomConfigurator(eventNames:Vector.<String>=null) {
			super();
			_data = eventNames;
		}

		public function get data():* {
			return _data;
		}

		public function set data(value:*):void {
			_data = value;
		}

		public function execute(instance:*, objectDefinition:IObjectDefinition):void {
		}
	}
}
