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
package org.springextensions.actionscript.ioc.config.impl {

	import org.as3commons.lang.Assert;
	import org.springextensions.actionscript.ioc.config.IObjectReference;

	/**
	 * Immutable placeholder class used for a property value object when it is
	 * a reference to another object in the factory, to be resolved at runtime.
	 * <p>
	 * <b>Author:</b> Christophe Herreman<br/>
	 * <b>Version:</b> $Revision: 21 $, $Date: 2008-11-01 22:58:42 +0100 (za, 01 nov 2008) $, $Author: dmurat $<br/>
	 * <b>Since:</b> 0.1
	 * </p>
	 */
	public class RuntimeObjectReference implements IObjectReference {

		private var _objectName:String = "";

		/**
		 * Creates a new RuntimeObjectReference.
		 */
		public function RuntimeObjectReference(objectName:String) {
			super();
			initRuntimeObjectReference(objectName);
		}

		protected function initRuntimeObjectReference(objectName:String):void {
			Assert.hasText(objectName, "The object name must have text");
			_objectName = objectName;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectName():String {
			return _objectName;
		}
	}
}
