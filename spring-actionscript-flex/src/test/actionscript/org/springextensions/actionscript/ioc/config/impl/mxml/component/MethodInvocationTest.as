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
package org.springextensions.actionscript.ioc.config.impl.mxml.component {
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class MethodInvocationTest {
		private var _invocation:org.springextensions.actionscript.ioc.config.impl.mxml.component.MethodInvocation;
		private var _invocationDefinition:org.springextensions.actionscript.ioc.impl.MethodInvocation;

		public function MethodInvocationTest() {
			super();
		}

		[Before]
		public function setUp():void {
			_invocation = new org.springextensions.actionscript.ioc.config.impl.mxml.component.MethodInvocation();
		}

		[Test]
		public function testName():void {
			_invocation.methodName = "testName";
			_invocationDefinition = _invocation.toMethodInvocation();
			assertEquals("testName", _invocationDefinition.methodName);
		}

		[Test]
		public function testNamespaceURI():void {
			_invocation.namespaceURI = "testNamespace";
			_invocationDefinition = _invocation.toMethodInvocation();
			assertEquals("testNamespace", _invocationDefinition.namespaceURI);
		}

		[Test]
		public function testNoArguments():void {
			_invocationDefinition = _invocation.toMethodInvocation();
			assertNull(_invocationDefinition.arguments);
		}

		[Test]
		public function testWithOneStringArgument():void {
			var arg1:Arg = new Arg();
			arg1.value = "test";
			_invocation.arguments[_invocation.arguments.length] = arg1;
			_invocationDefinition = _invocation.toMethodInvocation();
			assertNotNull(_invocationDefinition.arguments);
			assertEquals(1, _invocationDefinition.arguments.length);
			assertEquals("test", _invocationDefinition.arguments[0]);
		}

		[Test]
		public function testWithTwoArguments():void {
			var arg1:Arg = new Arg();
			arg1.value = "test";
			var arg2:Arg = new Arg();
			var def:MXMLObjectDefinition = new MXMLObjectDefinition();
			arg2.ref = def;
			_invocation.arguments[_invocation.arguments.length] = arg1;
			_invocation.arguments[_invocation.arguments.length] = arg2;
			_invocationDefinition = _invocation.toMethodInvocation();
			assertNotNull(_invocationDefinition.arguments);
			assertEquals(2, _invocationDefinition.arguments.length);
			assertEquals("test", _invocationDefinition.arguments[0]);
			assertStrictlyEquals(def, _invocationDefinition.arguments[1]);
		}
	}
}
