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
package org.springextensions.actionscript.ioc.impl {
	import org.as3commons.lang.ICloneable;

	/**
	 *
	 * @author Christophe Herreman
	 *
	 */
	public class MethodInvocation implements ICloneable {

		/**
		 * Creates a new <code>MethodInvocation</code> instance.
		 * @param methodName The name of the method that needs to be invoked.
		 * @param args Optional array of arguments for the method invocation.
		 *
		 */
		public function MethodInvocation(methodName:String, args:Array=null, ns:String=null) {
			super();
			_methodName = methodName;
			_arguments = args;
			_namespaceURI = ns;
		}

		private var _arguments:Array;
		private var _methodName:String;
		private var _namespaceURI:String;
		private var _requiresDependencies:Boolean = true;

		/**
		 * Optional array of arguments for the method invocation.
		 */
		public function get arguments():Array {
			return _arguments;
		}

		/**
		 *  The name of the method that needs to be invoked.
		 */
		public function get methodName():String {
			return _methodName;
		}

		public function get namespaceURI():String {
			return _namespaceURI;
		}

		public function get requiresDependencies():Boolean {
			return _requiresDependencies;
		}

		public function set requiresDependencies(value:Boolean):void {
			_requiresDependencies = value;
		}

		public function clone():* {
			return new MethodInvocation(this.methodName, this.arguments, this.namespaceURI);
		}
	}
}
