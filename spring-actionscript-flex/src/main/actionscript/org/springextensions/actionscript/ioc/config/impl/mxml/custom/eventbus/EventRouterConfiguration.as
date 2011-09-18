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
package org.springextensions.actionscript.ioc.config.impl.mxml.custom.eventbus {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import mx.core.IMXMLObject;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventRouterConfiguration extends EventDispatcher implements IMXMLObject {
		public static const DOCUMENT_CHANGED_EVENT:String = "documentChanged";
		public static const EVENTNAMES_CHANGED_EVENT:String = "eventNamesChanged";
		public static const ID_CHANGED_EVENT:String = "idChanged";
		public static const TOPICPROPERTIES_CHANGED_EVENT:String = "topicPropertiesChanged";
		public static const TOPICS_CHANGED_EVENT:String = "topicsChanged";

		/**
		 * Creates a new <code>EventRouterConfiguration</code> instance.
		 */
		public function EventRouterConfiguration(target:IEventDispatcher=null) {
			super(target);
		}

		private var _document:Object;
		private var _eventNames:String;
		private var _id:String;
		private var _topicProperties:String;
		private var _topics:String;

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

		[Bindable(event="eventNamesChanged")]
		public function get eventNames():String {
			return _eventNames;
		}

		public function set eventNames(value:String):void {
			if (_eventNames != value) {
				_eventNames = value;
				dispatchEvent(new Event(EVENTNAMES_CHANGED_EVENT));
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

		[Bindable(event="topicPropertiesChanged")]
		public function get topicProperties():String {
			return _topicProperties;
		}

		public function set topicProperties(value:String):void {
			if (_topicProperties != value) {
				_topicProperties = value;
				dispatchEvent(new Event(TOPICPROPERTIES_CHANGED_EVENT));
			}
		}

		[Bindable(event="topicsChanged")]
		public function get topics():String {
			return _topics;
		}

		public function set topics(value:String):void {
			if (_topics != value) {
				_topics = value;
				dispatchEvent(new Event(TOPICS_CHANGED_EVENT));
			}
		}

		public function initialized(document:Object, id:String):void {
			_document = document;
			_id = id;
		}
	}
}
