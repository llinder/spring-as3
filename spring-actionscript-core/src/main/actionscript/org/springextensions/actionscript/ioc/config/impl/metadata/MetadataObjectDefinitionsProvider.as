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
package org.springextensions.actionscript.ioc.config.impl.metadata {
	import flash.display.LoaderInfo;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.lang.IDisposable;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class MetadataObjectDefinitionsProvider implements IObjectDefinitionsProvider, IDisposable, IApplicationContextAware, ILoaderInfoAware {

		/**
		 * Creates a new <code>MetadataObjectDefinitionsProvider</code> instance.
		 */
		public function MetadataObjectDefinitionsProvider() {
			super();
		}

		private var _applicationContext:IApplicationContext;
		private var _isDisposed:Boolean;
		private var _objectDefinitions:Object;
		private var _propertiesProvider:IPropertiesProvider;
		private var _propertyURIs:Vector.<TextFileURI>;

		public function get applicationContext():IApplicationContext {
			return _applicationContext;
		}

		public function set applicationContext(value:IApplicationContext):void {
			_applicationContext = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		/**
		 * @inheritDoc
		 */
		public function get loaderInfo():LoaderInfo {
			return (_applicationContext is ILoaderInfoAware) ? ILoaderInfoAware(_applicationContext).loaderInfo : null;
		}

		/**
		 * @private
		 */
		public function set loaderInfo(value:LoaderInfo):void {
			if (_applicationContext is ILoaderInfoAware) {
				ILoaderInfoAware(_applicationContext).loaderInfo = value;
			}
		}

		public function get objectDefinitions():Object {
			return _objectDefinitions;
		}

		public function get propertiesProvider():IPropertiesProvider {
			return _propertiesProvider;
		}

		public function get propertyURIs():Vector.<TextFileURI> {
			return _propertyURIs;
		}

		public function createDefinitions():IOperation {
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			if (!_isDisposed) {
				_isDisposed = true;
			}
		}
	}
}
