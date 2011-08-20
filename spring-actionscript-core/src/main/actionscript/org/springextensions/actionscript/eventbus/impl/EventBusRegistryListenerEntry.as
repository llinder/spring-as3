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
package org.springextensions.actionscript.eventbus.impl {
	import org.as3commons.reflect.MethodInvoker;
	import org.springextensions.actionscript.eventbus.process.EventHandlerProxy;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventBusRegistryListenerEntry {

		private var _eventTypes:Vector.<EventListenerEntry>;
		private var _classes:Vector.<ClassListenerEntry>;
		private var _proxy:EventHandlerProxy;

		/**
		 *
		 * @param proxy
		 * @param types
		 * @param topics
		 */
		public function EventBusRegistryListenerEntry(proxy:EventHandlerProxy, types:Vector.<EventListenerEntry>=null, classes:Vector.<ClassListenerEntry>=null) {
			super();
			initEvenBusRegistryListenerEntry(proxy, types, classes);
		}

		public function get classes():Vector.<ClassListenerEntry> {
			return _classes;
		}

		public function get eventTypes():Vector.<EventListenerEntry> {
			return _eventTypes;
		}

		public function get proxy():EventHandlerProxy {
			return _proxy;
		}

		protected function initEvenBusRegistryListenerEntry(proxy:EventHandlerProxy, types:Vector.<EventListenerEntry>, classes:Vector.<ClassListenerEntry>):void {
			_proxy = proxy;
			_eventTypes = types ||= new Vector.<EventListenerEntry>();
			_classes = classes ||= new Vector.<ClassListenerEntry>();
		}
	}
}
