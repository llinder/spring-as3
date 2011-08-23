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
package org.springextensions.actionscript.context.impl.mxml {
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import mx.core.IMXMLObject;

	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.context.config.IConfigurationPackage;
	import org.springextensions.actionscript.context.impl.ApplicationContext;
	import org.springextensions.actionscript.ioc.config.impl.mxml.MXMLObjectDefinitionsProvider;
	import org.springextensions.actionscript.util.ContextUtils;

	[Event(name="complete", type="flash.events.Event")]
	/**
	 *
	 * @author Roland Zwaga
	 */
	public class MXMLApplicationContext extends EventDispatcher implements IMXMLObject, IApplicationContextAware {
		public static const AUTOLOAD_CHANGED_EVENT:String = "autoLoadChanged";
		public static const CONFIGURATIONS_CHANGED_EVENT:String = "configurationsChanged";
		public static const DOCUMENT_CHANGED_EVENT:String = "documentChanged";
		public static const ID_CHANGED_EVENT:String = "idChanged";
		public static const CONFIGURATIONPACKAGE_CHANGED_EVENT:String = "configurationPackageChanged";

		public function MXMLApplicationContext() {
			super();
		}

		private var _applicationContext:IApplicationContext;
		private var _autoLoad:Boolean = false;
		private var _configurations:Array;
		private var _configurationPackage:IConfigurationPackage;
		private var _document:Object;

		private var _id:String;


		[Bindable(event="configurationPackageChanged")]
		public function get configurationPackage():IConfigurationPackage {
			return _configurationPackage;
		}

		public function set configurationPacks(value:IConfigurationPackage):void {
			if (_configurationPackage !== value) {
				_configurationPackage = value;
				dispatchEvent(new Event(CONFIGURATIONPACKAGE_CHANGED_EVENT));
			}
		}

		public function get applicationContext():IApplicationContext {
			return _applicationContext;
		}

		public function set applicationContext(value:IApplicationContext):void {
			_applicationContext = value;
		}

		[Bindable(event="autoLoadChanged")]
		public function get autoLoad():Boolean {
			return _autoLoad;
		}

		public function set autoLoad(value:Boolean):void {
			if (_autoLoad != value) {
				_autoLoad = value;
				dispatchEvent(new Event(AUTOLOAD_CHANGED_EVENT));
			}
		}

		[Bindable(event="configurationsChanged")]
		public function get configurations():Array {
			return _configurations;
		}

		public function set configurations(value:Array):void {
			if (_configurations != value) {
				_configurations = value;
				dispatchEvent(new Event(CONFIGURATIONS_CHANGED_EVENT));
			}
		}

		[Bindable(event="documentChanged")]
		public function get document():Object {
			return _document;
		}

		public function set document(value:Object):void {
			if (_document != value) {
				_document = value;
				dispatchEvent(new Event(DOCUMENT_CHANGED_EVENT));
			}
		}

		[Bindable(event="idChanged")]
		public function get id():String {
			return _id;
		}

		public function set id(value:String):void {
			if (_id != value) {
				_id = value;
				dispatchEvent(new Event(ID_CHANGED_EVENT));
			}
		}

		public function initialized(document:Object, id:String):void {
			_document = document;
			_id = id;
			_applicationContext = new ApplicationContext();
			_applicationContext.addDefinitionProvider(new MXMLObjectDefinitionsProvider());
			if (_configurationPackage != null) {
				_applicationContext.configure(_configurationPackage);
			}
			ContextUtils.disposeInstance(_configurationPackage);
			_configurationPackage = null;
			if (autoLoad) {
				doLoad();
			}
		}

		public function load():void {
			doLoad();
		}

		protected function doLoad():void {
			for each (var cls:Class in _configurations) {
				MXMLObjectDefinitionsProvider(_applicationContext.definitionProviders[0]).addConfiguration(cls);
			}
			_applicationContext.addEventListener(Event.COMPLETE, handleApplicationContextComplete);
			_applicationContext.load();
		}

		protected function handleApplicationContextComplete(event:Event):void {
			_applicationContext.removeEventListener(Event.COMPLETE, handleApplicationContextComplete);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
