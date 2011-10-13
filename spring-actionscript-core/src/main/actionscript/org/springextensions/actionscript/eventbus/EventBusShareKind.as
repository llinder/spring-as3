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
package org.springextensions.actionscript.eventbus {
	import flash.utils.Dictionary;
	import org.as3commons.lang.Assert;

	/**
	 * Determines the way two eventbuses share their events.
	 * @author Roland Zwaga
	 */
	public final class EventBusShareKind {

		private static const TYPES:Object = {};
		private static var _isCreated:Boolean = false;

		public static const NONE:EventBusShareKind = new EventBusShareKind("ShareNothing");
		public static const BOTH_WAYS:EventBusShareKind = new EventBusShareKind("ListenBothWays");
		public static const CHILD_LISTENS_TO_PARENT:EventBusShareKind = new EventBusShareKind("ChildListensToParent");
		public static const PARENT_LISTENS_TO_CHILD:EventBusShareKind = new EventBusShareKind("ParentListensToChild");


		public static function fromValue(val:String):EventBusShareKind {
			return TYPES[val];
		}

		{
			_isCreated = true;
		}

		/**
		 * Creates a new <code>EventBusShareKind</code> instance.
		 */
		public function EventBusShareKind(val:String) {
			Assert.state((_isCreated == false), "The EventBusShareKind enum has already been created");
			super();
			_value = val;
			TYPES[val] = this;
		}

		private var _value:String;

		public function get value():String {
			return _value;
		}
	}
}
