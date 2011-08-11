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
package org.springextensions.actionscript.ioc.factory.impl {
	import flash.events.EventDispatcher;

	import org.as3commons.lang.IDisposable;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.event.InstanceCacheEvent;
	import org.springextensions.actionscript.ioc.objectdefinition.error.ObjectDefinitionNotFoundError;
	import org.springextensions.actionscript.util.ContextUtils;

	/**
	 *
	 */
	[Event(name="instancePrepared", type="org.springextensions.actionscript.ioc.factory.event.InstanceCacheEvent")]
	/**
	 *
	 */
	[Event(name="instanceAdded", type="org.springextensions.actionscript.ioc.factory.event.InstanceCacheEvent")]
	/**
	 *
	 */
	[Event(name="instanceRemoved", type="org.springextensions.actionscript.ioc.factory.event.InstanceCacheEvent")]
	/**
	 *
	 */
	[Event(name="cacheCleared", type="org.springextensions.actionscript.ioc.factory.event.InstanceCacheEvent")]
	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultInstanceCache extends EventDispatcher implements IInstanceCache, IDisposable {

		/**
		 * Creates a new <code>DefaultInstanceCache</code> instance.
		 *
		 */
		public function DefaultInstanceCache() {
			super();
			initDefaultInstanceCache();
		}

		private var _cache:Object;
		private var _cachedNames:Vector.<String>;
		private var _preparedCache:Object;
		private var _isDisposed:Boolean;

		/**
		 * @inheritDoc
		 */
		public function addInstance(name:String, instance:*):void {
			if (!hasInstance(name)) {
				_cachedNames[_cachedNames.length] = name;
			}
			_cache[name] = instance;
			removePreparedInstance(name);
			dispatchCacheEvent(InstanceCacheEvent.INSTANCE_ADDED, name, instance);
		}

		protected function dispatchCacheEvent(type:String, name:String=null, instance:*=null):void {
			dispatchEvent(new InstanceCacheEvent(type, name, instance));
		}

		/**
		 * @inheritDoc
		 */
		public function clearCache():void {
			clearCacheObject(_cache);
			clearCacheObject(_preparedCache);
			initDefaultInstanceCache();
			dispatchCacheEvent(InstanceCacheEvent.CLEARED);
		}

		/**
		 * @inheritDoc
		 */
		public function getCachedNames():Vector.<String> {
			return _cachedNames.concat.apply(this);
		}

		/**
		 * @inheritDoc
		 */
		public function getInstance(name:String):* {
			if (hasInstance(name)) {
				return _cache[name];
			} else {
				throw new ObjectDefinitionNotFoundError(name);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function getPreparedInstance(name:String):* {
			if (isPrepared(name)) {
				return _preparedCache[name];
			} else {
				throw new ObjectDefinitionNotFoundError(name);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function hasInstance(name:String):Boolean {
			return _cache.hasOwnProperty(name);
		}

		/**
		 * @inheritDoc
		 */
		public function isPrepared(name:String):Boolean {
			return _preparedCache.hasOwnProperty(name);
		}

		/**
		 * @inheritDoc
		 */
		public function numInstances():uint {
			return _cachedNames.length;
		}

		/**
		 * @inheritDoc
		 */
		public function prepareInstance(name:String, instance:*):void {
			_preparedCache[name] = instance;
			dispatchCacheEvent(InstanceCacheEvent.INSTANCE_PREPARED, name, instance);
		}

		/**
		 * @inheritDoc
		 */
		public function removeInstance(name:String):* {
			if (hasInstance(name)) {
				var instance:* = _cache[name];
				delete _cache[name];
				var idx:int = _cachedNames.indexOf(name);
				if (idx > -1) {
					_cachedNames.splice(idx, 1);
					dispatchCacheEvent(InstanceCacheEvent.INSTANCE_REMOVED, name, instance);
				}
				return instance;
			}
			return null;
		}

		/**
		 * Initializes the current <code>DefaultInstanceCache</code> by creating the internal cache objects and lists.
		 *
		 */
		protected function initDefaultInstanceCache():void {
			_preparedCache = {};
			_cache = {};
			_cachedNames = new Vector.<String>();
		}

		/**
		 *
		 * @param name
		 */
		protected function removePreparedInstance(name:String):void {
			if (isPrepared(name)) {
				delete _preparedCache[name];
			}
		}

		/**
		 *
		 * @param cacheObject
		 */
		protected function clearCacheObject(cacheObject:Object):void {
			for (var name:String in cacheObject) {
				ContextUtils.disposeInstance(cacheObject[name]);
				delete cacheObject[name];
			}
		}

		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		public function dispose():void {
			if (!isDisposed) {
				clearCacheObject(_cache);
				_cache = null;
				clearCacheObject(_preparedCache);
				_preparedCache = null;
				_cachedNames = null;
				_isDisposed = true;
			}
		}
	}
}
