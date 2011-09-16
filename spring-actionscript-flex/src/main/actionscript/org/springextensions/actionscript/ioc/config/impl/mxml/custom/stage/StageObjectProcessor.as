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
package org.springextensions.actionscript.ioc.config.impl.mxml.custom.stage {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.config.impl.mxml.ICustomObjectDefinitionComponent;
	import org.springextensions.actionscript.ioc.config.impl.mxml.component.MXMLObjectDefinition;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class StageObjectProcessor extends MXMLObjectDefinition implements ICustomObjectDefinitionComponent, IEventDispatcher {

		public static const OBJECTSELECTOR_CHANGED_EVENT:String = "objectSelectorChanged";

		private var _eventDispatcher:IEventDispatcher = new EventDispatcher();

		/**
		 * Creates a new <code>StageObjectProcessor</code> instance.
		 */
		public function StageObjectProcessor() {
			super();
		}

		private var _objectSelector:Object;

		[Bindable(event="objectSelectorChanged")]
		public function get objectSelector():Object {
			return _objectSelector;
		}

		public function set objectSelector(value:Object):void {
			if (_objectSelector != value) {
				_objectSelector = value;
				dispatchEvent(new Event(OBJECTSELECTOR_CHANGED_EVENT));
			}
		}

		public function execute(applicationContext:IApplicationContext, objectDefinitions:Object):void {
			definition.customConfiguration = resolveObjectSelectorName();
			objectDefinitions[this.id] = definition;
		}

		protected function resolveObjectSelectorName():* {
			return (_objectSelector is MXMLObjectDefinition) ? MXMLObjectDefinition(_objectSelector).id : _objectSelector;
		}

		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}

		public function dispatchEvent(event:Event):Boolean {
			return _eventDispatcher.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean {
			return _eventDispatcher.hasEventListener(type);
		}

		public function willTrigger(type:String):Boolean {
			return _eventDispatcher.willTrigger(type);
		}

	}
}
