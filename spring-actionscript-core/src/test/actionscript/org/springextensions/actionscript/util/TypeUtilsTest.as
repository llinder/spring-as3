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
	import org.as3commons.reflect.Type;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;

	public class TypeUtilsTest {

		public function TypeUtilsTest() {
			super();
		}

		[Test]
		public function testIsSimpleWithNumber():void {
			var type:Type = Type.forClass(Number);
			var result:Boolean = TypeUtils.isSimpleProperty(type);
			assertTrue(result);
		}

		[Test]
		public function testIsSimpleWithInt():void {
			var type:Type = Type.forClass(int);
			var result:Boolean = TypeUtils.isSimpleProperty(type);
			assertTrue(result);
		}

		[Test]
		public function testIsSimpleWithUint():void {
			var type:Type = Type.forClass(uint);
			var result:Boolean = TypeUtils.isSimpleProperty(type);
			assertTrue(result);
		}

		[Test]
		public function testIsSimpleWithArray():void {
			var type:Type = Type.forClass(Array);
			var result:Boolean = TypeUtils.isSimpleProperty(type);
			assertTrue(result);
		}

		[Test]
		public function testIsSimpleWithString():void {
			var type:Type = Type.forClass(String);
			var result:Boolean = TypeUtils.isSimpleProperty(type);
			assertTrue(result);
		}

		[Test]
		public function testIsSimpleWithDate():void {
			var type:Type = Type.forClass(Date);
			var result:Boolean = TypeUtils.isSimpleProperty(type);
			assertTrue(result);
		}

		[Test]
		public function testIsSimpleWithObject():void {
			var type:Type = Type.forClass(Object);
			var result:Boolean = TypeUtils.isSimpleProperty(type);
			assertFalse(result);
		}
	}
}
