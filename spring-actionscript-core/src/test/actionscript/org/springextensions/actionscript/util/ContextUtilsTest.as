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
package org.springextensions.actionscript.util {
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.verify;

	import org.as3commons.lang.IDisposable;
	import org.flexunit.asserts.assertTrue;


	public class ContextUtilsTest {

		[Rule]
		public var mockolateRule:MockolateRule = new MockolateRule();

		[Mock]
		public var disposable:IDisposable;
		[Mock]
		public var object:Object;

		public function ContextUtilsTest() {
			super();
		}

		[Test]
		public function testDisposeInstanceWithRegularObject():void {
			var obj:Object = nice(Object);
			mock(obj).method("dispose").never();
			ContextUtils.disposeInstance(obj);
			verify(obj);
		}

		[Test]
		public function testDisposeInstanceWithIDisposableImplementation():void {
			disposable = nice(IDisposable);
			mock(disposable).method("dispose").once();
			ContextUtils.disposeInstance(disposable);
			verify(disposable);
		}
	}
}