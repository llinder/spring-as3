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
package org.springextensions.actionscript.stage {

	import flash.display.DisplayObject;

	import org.as3commons.stageprocessing.IStageObjectDestroyer;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IObjectFactoryAware;

	/**
	 *
	 * @author rolandzwaga
	 */
	public class DefaultStageObjectDestroyer implements IObjectFactoryAware, IStageObjectDestroyer {
		private var _objectFactory:IObjectFactory;

		/**
		 * Creates a new <code>DefaultStageObjectDestroyer</code> instance.
		 */
		public function DefaultStageObjectDestroyer() {
			super();
		}

		public function set objectFactory(objectFactory:IObjectFactory):void {
			_objectFactory = objectFactory;
		}

		public function destroy(displayObject:DisplayObject):DisplayObject {
			if (_objectFactory != null) {
				_objectFactory.destroyObject(displayObject);
			}
			return displayObject;
		}

		public function process(displayObject:DisplayObject):DisplayObject {
			return displayObject;
		}
	}
}
