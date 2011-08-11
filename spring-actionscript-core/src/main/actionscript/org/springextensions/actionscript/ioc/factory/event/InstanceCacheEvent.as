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
package org.springextensions.actionscript.ioc.factory.event {

	import flash.events.Event;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class InstanceCacheEvent extends Event {

		public static const INSTANCE_PREPARED:String = "instancePrepared";
		public static const INSTANCE_ADDED:String = "instanceAdded";
		public static const INSTANCE_REMOVED:String = "instanceRemoved";
		public static const CLEARED:String = "cacheCleared";

		private var _cachedInstance:*;
		private var _cacheName:String;

		/**
		 * Creates a new <code>InstanceCacheEvent</code> instance.
		 * @param type
		 * @param name
		 * @param instance
		 * @param bubbles
		 * @param cancelable
		 */
		public function InstanceCacheEvent(type:String, name:String=null, instance:*=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			_cachedInstance = instance;
			_cacheName = name;
		}

		public function get cachedInstance():* {
			return _cachedInstance;
		}

		public function get cacheName():String {
			return _cacheName;
		}

		override public function clone():Event {
			return new InstanceCacheEvent(type, _cachedInstance, _cacheName, bubbles, cancelable);
		}

	}
}
