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

	import org.as3commons.lang.IDisposable;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.objectdefinition.error.ObjectDefinitionNotFoundError;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultInstanceCache implements IInstanceCache {

		private var _cache:Object;
		private var _count:uint;

		public function DefaultInstanceCache() {
			super();
			initDefaultInstanceCache();
		}

		protected function initDefaultInstanceCache():void {
			_cache = {};
			_count = 0;
		}

		public function getInstance(name:String):* {
			if (hasInstance(name)) {
				return _cache[name];
			} else {
				throw new ObjectDefinitionNotFoundError(name);
			}
		}

		public function clearCache():void {
			for (var name:String in _cache) {
				var inst:IDisposable = getInstance(name) as IDisposable;
				if (inst != null) {
					if (!inst.isDisposed) {
						inst.dispose();
					}
				}
			}
			initDefaultInstanceCache();
		}

		public function numInstances():uint {
			return _count;
		}

		public function addInstance(name:String, instance:*):void {
			if (!hasInstance(name)) {
				_count++;
			}
			_cache[name] = instance;
		}

		public function removeInstance(name:String):void {
			if (hasInstance(name)) {
				delete _cache[name];
				_count--;
			}
		}

		public function hasInstance(name:String):Boolean {
			return _cache.hasOwnProperty(name);
		}
	}
}
