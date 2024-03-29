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
package org.springextensions.actionscript.ioc.config.impl.mxml.custom {

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;

	import mx.core.IMXMLObject;
	import mx.utils.UIDUtil;

	import org.as3commons.lang.StringUtils;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.config.impl.mxml.ICustomObjectDefinitionComponent;


	/**
	 *
	 * @author Roland Zwaga
	 */
	public class AbstractCustomObjectDefinitionComponent extends EventDispatcher implements ICustomObjectDefinitionComponent, IMXMLObject {

		private var _id:String;
		private var _document:Object;

		/**
		 * Creates a new <code>AbstractCustomObjectDefinitionComponent</code> instance.
		 */
		public function AbstractCustomObjectDefinitionComponent() {
			super();
		}

		public function get id():String {
			return _id;
		}

		public function set id(value:String):void {
			_id = value;
		}

		public function get document():Object {
			return _document;
		}

		public function set document(value:Object):void {
			_document = value;
		}

		public function initialized(document:Object, id:String):void {
			_id = id;
			_document = document;
			_id = (StringUtils.hasText(id)) ? id : UIDUtil.createUID();
		}

		public function execute(applicationContext:IApplicationContext, objectDefinitions:Object):void {
			throw new IllegalOperationError("execute() not implemented in abstract base class");
		}

	}
}
