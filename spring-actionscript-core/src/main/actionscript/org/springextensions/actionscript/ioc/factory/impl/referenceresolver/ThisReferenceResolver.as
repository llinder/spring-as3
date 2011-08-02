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
package org.springextensions.actionscript.ioc.factory.impl.referenceresolver {
	import org.as3commons.lang.IOrdered;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.config.IObjectReference;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;

	/**
	 * Returns its <code>IApplicationContext</code> reference when a property with the value 'this' is encountered.
	 * @author Roland Zwaga
	 */
	public class ThisReferenceResolver implements IReferenceResolver, IOrdered {

		public static const THIS_PROPERTY_VALUE:String = "this";

		private var _applicationContext:IApplicationContext;
		private var _order:int;

		/**
		 * Creates a new <code>ThisReferenceResolver</code> instance.
		 * @param context The specified <code>IApplicationContext</code> instance.
		 */
		public function ThisReferenceResolver(context:IApplicationContext) {
			super();
			initThisReferenceResolver(context);
		}

		/**
		 * Initializes the current <code>ThisReferenceResolver</code>.
		 * @param context The specified <code>IApplicationContext</code> instance.
		 */
		protected function initThisReferenceResolver(context:IApplicationContext):void {
			_applicationContext = context;
			_order = 0;
		}

		/**
		 * Returns <code>true</code> when the specified property is a <code>String</code> and its value is 'this'.
		 * @param property The specified property.
		 * @return <code>True</code> when the specified property is a <code>String</code> and its value is 'this'.
		 */
		public function canResolve(property:Object):Boolean {
			if (property is String) {
				return (String(property).toLowerCase() == THIS_PROPERTY_VALUE);
			} else if (property is IObjectReference) {
				return (IObjectReference(property).objectName.toLowerCase() == THIS_PROPERTY_VALUE);
			}
			return false;
		}

		/**
		 * Return the <code>IApplicationContext</code> instance.
		 * @param property The specified property.
		 * @return The <code>IApplicationContext</code> instance.
		 */
		public function resolve(property:Object):Object {
			return _applicationContext;
		}

		public function get order():int {
			return _order;
		}

		public function set order(value:int):void {
			_order = value;
		}
	}
}
