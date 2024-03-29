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

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import mx.core.IMXMLObject;
	import flash.events.Event;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class InterceptionConfiguration extends EventDispatcher implements IMXMLObject {
		public static const ID_CHANGED_EVENT:String = "idChanged";
		public static const DOCUMENT_CHANGED_EVENT:String = "documentChanged";
		public static const EVENTNAME_CHANGED_EVENT:String = "eventNameChanged";
		public static const EVENTCLASS_CHANGED_EVENT:String = "eventClassChanged";
		public static const TOPICS_CHANGED_EVENT:String = "topicsChanged";
		public static const TOPICPROPERTIES_CHANGED_EVENT:String = "topicPropertiesChanged";

		private var _id:String;
		private var _document:Object;
		private var _eventName:String;
		private var _eventClass:Class;
		private var _topics:String;
		private var _topicProperties:String;

		/**
		 * Creates a new <code>InterceptionConfiguration</code> instance.
		 */
		public function InterceptionConfiguration() {
			super();
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

		[Bindable(event="eventNameChanged")]
		public function get eventName():String {
			return _eventName;
		}

		public function set eventName(value:String):void {
			if (_eventName != value) {
				_eventName = value;
				dispatchEvent(new Event(EVENTNAME_CHANGED_EVENT));
			}
		}

		[Bindable(event="eventClassChanged")]
		public function get eventClass():Class {
			return _eventClass;
		}

		public function set eventClass(value:Class):void {
			if (_eventClass != value) {
				_eventClass = value;
				dispatchEvent(new Event(EVENTCLASS_CHANGED_EVENT));
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

		public function initialized(document:Object, id:String):void {
			_document = document;
			_id = id;
		}
	}
}
