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
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.eventbus.IEventBusAware;
	import org.as3commons.eventbus.IEventInterceptor;
	import org.as3commons.eventbus.IEventListenerInterceptor;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.SoftReference;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.reflect.MethodInvoker;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.eventbus.process.EventHandlerProxy;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultEventBusUserRegistry implements IEventBusUserRegistry, IEventBusAware, IDisposable {

		private static const LOGGER:ILogger = getLogger(DefaultEventBusUserRegistry);

		public function DefaultEventBusUserRegistry() {
			super();
			initEventBusRegistry();
		}

		private var _eventBus:IEventBus;
		private var _eventBusRegistryEntryCache:Dictionary;
		private var _isDisposed:Boolean;
		private var _listenerCache:Dictionary;
		private var _proxies:Dictionary;
		private var _typesLookup:Dictionary;

		/**
		 * @inheritDoc
		 */
		public function get eventBus():IEventBus {
			return _eventBus;
		}

		/**
		 * @private
		 */
		public function set eventBus(value:IEventBus):void {
			_eventBus = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		/**
		 *
		 * @param eventClass
		 * @param interceptor
		 * @param topic
		 */
		public function addEventClassInterceptor(eventClass:Class, interceptor:IEventInterceptor, topic:Object=null):void {
			var registryItem:EventBusRegistryEntry = _eventBusRegistryEntryCache[interceptor] ||= new EventBusRegistryEntry(interceptor);
			registryItem.classEntries[registryItem.classEntries.length] = new ClassEntry(eventClass, topic);
			_eventBus.addEventClassInterceptor(eventClass, interceptor, topic);
		}

		public function addEventClassListenerInterceptor(eventClass:Class, interceptor:IEventListenerInterceptor, topic:Object=null):void {
			var registryItem:EventBusRegistryEntry = _eventBusRegistryEntryCache[interceptor] ||= new EventBusRegistryEntry(interceptor);
			registryItem.classEntries[registryItem.classEntries.length] = new ClassEntry(eventClass, topic);
			_eventBus.addEventClassListenerInterceptor(eventClass, interceptor, topic);
		}

		public function addEventClassListenerProxy(eventClass:Class, proxy:MethodInvoker, useWeakReference:Boolean=false, topic:Object=null):Boolean {
			var registryItem:EventBusRegistryEntry = _eventBusRegistryEntryCache[proxy] ||= new EventBusRegistryEntry(proxy);
			registryItem.classEntries[registryItem.classEntries.length] = new ClassEntry(eventClass, topic);
			return _eventBus.addEventClassListenerProxy(eventClass, proxy, useWeakReference, topic);
		}

		/**
		 *
		 * @param type
		 * @param interceptor
		 * @param topic
		 */
		public function addEventInterceptor(type:String, interceptor:IEventInterceptor, topic:Object=null):void {
			var registryItem:EventBusRegistryEntry = _eventBusRegistryEntryCache[interceptor] ||= new EventBusRegistryEntry(interceptor);
			registryItem.eventTypeEntries[registryItem.eventTypeEntries.length] = new EventTypeEntry(type, topic);
			_eventBus.addEventInterceptor(type, interceptor, topic);
		}

		public function addEventListenerInterceptor(type:String, interceptor:IEventListenerInterceptor, topic:Object=null):void {
			var registryItem:EventBusRegistryEntry = _eventBusRegistryEntryCache[interceptor] ||= new EventBusRegistryEntry(interceptor);
			registryItem.eventTypeEntries[registryItem.eventTypeEntries.length] = new EventTypeEntry(type, topic);
			_eventBus.addEventListenerInterceptor(type, interceptor, topic);
		}

		public function addEventListenerProxy(type:String, proxy:MethodInvoker, useWeakReference:Boolean=false, topic:Object=null):Boolean {
			var registryItem:EventBusRegistryEntry = _eventBusRegistryEntryCache[proxy] ||= new EventBusRegistryEntry(proxy);
			registryItem.eventTypeEntries[registryItem.eventTypeEntries.length] = new EventTypeEntry(type, topic);
			return _eventBus.addEventListenerProxy(type, proxy, useWeakReference, topic);
		}

		/**
		 *
		 * @param eventDispatcher
		 * @param eventTypes
		 * @param topics
		 */
		public function addEventListeners(eventDispatcher:IEventDispatcher, eventTypes:Array, topics:Array):void {
			for each (var eventType:String in eventTypes) {
				var types:Array = _listenerCache[eventDispatcher] as Array;
				if (types == null) {
					types = [];
					_listenerCache[eventDispatcher] = types;
				}
				types[types.length] = eventType;
				if (topics.length > 0) {
					_typesLookup[eventType] = topics;
				}
				eventDispatcher.addEventListener(eventType, rerouteToEventBus, false, 0, true);
				LOGGER.debug("added listener for event type '" + eventType + "' on " + eventDispatcher);
			}
		}

		/**
		 *
		 * @param interceptor
		 * @param topic
		 */
		public function addInterceptor(interceptor:IEventInterceptor, topic:Object=null):void {
			var registryItem:EventBusRegistryEntry = _eventBusRegistryEntryCache[interceptor] ||= new EventBusRegistryEntry(interceptor);
			registryItem.eventTypeEntries[registryItem.eventTypeEntries.length] = new EventTypeEntry(null, topic);
			_eventBus.addInterceptor(interceptor, topic);
		}

		public function addListenerInterceptor(interceptor:IEventListenerInterceptor, topic:Object=null):void {
			var registryItem:EventBusRegistryEntry = _eventBusRegistryEntryCache[interceptor] ||= new EventBusRegistryEntry(interceptor);
			registryItem.eventTypeEntries[registryItem.eventTypeEntries.length] = new EventTypeEntry(null, topic);
			_eventBus.addListenerInterceptor(interceptor, topic);
		}

		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			if (!_isDisposed) {
				for (var dispatcher:* in _listenerCache) {
					if (dispatcher != null) {
						removeListeners(dispatcher as IEventDispatcher);
					}
					delete _listenerCache[dispatcher];
				}
				_listenerCache = null;
				for (var proxy:* in _eventBusRegistryEntryCache) {
					var entry:EventBusRegistryEntry = _eventBusRegistryEntryCache[proxy];
					var classEntry:ClassEntry;
					var eventEntry:EventTypeEntry;
					if (proxy is MethodInvoker) {
						for each (classEntry in entry.classEntries) {
							return _eventBus.removeEventClassListenerProxy(classEntry.clazz, proxy, classEntry.topic);
						}
						for each (eventEntry in entry.eventTypeEntries) {
							return _eventBus.removeEventListenerProxy(eventEntry.eventType, proxy, eventEntry.topic);
						}
					} else if (proxy is IEventInterceptor) {
						for each (classEntry in entry.classEntries) {
							return _eventBus.removeEventClassInterceptor(classEntry.clazz, proxy, classEntry.topic);
						}
						for each (eventEntry in entry.eventTypeEntries) {
							return _eventBus.removeEventInterceptor(eventEntry.eventType, proxy, eventEntry.topic);
						}
					} else if (proxy is IEventListenerInterceptor) {
						for each (classEntry in entry.classEntries) {
							return _eventBus.removeEventClassListenerInterceptor(classEntry.clazz, proxy, classEntry.topic);
						}
						for each (eventEntry in entry.eventTypeEntries) {
							return _eventBus.removeEventListenerInterceptor(eventEntry.eventType, proxy, eventEntry.topic);
						}
					}
				}
				_typesLookup = null;
				_isDisposed = true;
			}
		}

		/**
		 * Removes all the event listeners that were added to the specified <code>IEventDispatcher</code>.
		 */
		public function removeListeners(eventDispatcher:IEventDispatcher):void {
			var types:Array = _listenerCache[eventDispatcher] as Array;
			if (types != null) {
				for each (var type:String in types) {
					eventDispatcher.removeEventListener(type, rerouteToEventBus);
				}
			}
		}

		/**
		 * Initializes the current <code>DefaultEventBusUserRegistry</code>.
		 */
		protected function initEventBusRegistry():void {
			_listenerCache = new Dictionary(true);
			_eventBusRegistryEntryCache = new Dictionary();
			_typesLookup = new Dictionary();
			_proxies = new Dictionary(true);
		}

		/**
		 *
		 * @param eventClass
		 * @param handler
		 */
		protected function removeEventClassListener(eventClass:Class, handler:Function=null):void {
			for (var proxy:* in _proxies) {
				var key:* = _proxies[proxy];
				if (key is Class) {
					var cls:Class = Class(key);
					var m:MethodInvoker = MethodInvoker(proxy);
					if ((cls === eventClass) && ((handler == null) || (handler === m.target[m.method]))) {
						eventBus.removeEventClassListenerProxy(cls, m);
					}
				}
			}
		}

		/**
		 *
		 * @param eventName
		 * @param handler
		 */
		protected function removeEventListener(eventName:String, handler:Function=null):void {
			for (var proxy:* in _proxies) {
				var key:* = _proxies[proxy];
				if (key is String) {
					var name:String = String(key);
					var m:MethodInvoker = MethodInvoker(proxy);
					if ((name == eventName) && ((handler == null) || (handler === m.target[m.method]))) {
						eventBus.removeEventListenerProxy(name, m);
					}
				}
			}
		}

		/**
		 *
		 * @param event
		 */
		protected function rerouteToEventBus(event:Event):void {
			var topics:Array = _typesLookup[event.type] as Array;
			if (topics == null) {
				eventBus.dispatchEvent(event);
			} else {
				var toDelete:Array;
				for each (var topic:Object in topics) {
					if (topic is String) {
						eventBus.dispatchEvent(event, topic);
					} else {
						if (SoftReference(topic).value != null) {
							eventBus.dispatchEvent(event, SoftReference(topic).value);
						} else {
							toDelete ||= [];
							toDelete[toDelete.length] = topic
						}
					}
				}
				for each (var item:* in toDelete) {
					topics.splice(topics.indexOf(item), 1);
				}
			}
		}
	}
}
