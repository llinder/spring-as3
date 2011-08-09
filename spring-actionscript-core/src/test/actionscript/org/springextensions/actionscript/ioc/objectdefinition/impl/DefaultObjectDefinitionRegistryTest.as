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
package org.springextensions.actionscript.ioc.objectdefinition.impl {
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.test.testtypes.TestClassWithMetadata;

	public class DefaultObjectDefinitionRegistryTest {

		{
			TestClassWithMetadata;
		}

		private var _registry:DefaultObjectDefinitionRegistry;

		public function DefaultObjectDefinitionRegistryTest() {
			super();
		}

		[Before]
		public function setUp():void {
			_registry = new DefaultObjectDefinitionRegistry();
		}

		[Test]
		public function testRegisterObjectDefinition():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			assertEquals(0, _registry.numObjectDefinitions);
			_registry.registerObjectDefinition("test", objectDefinition);
			assertEquals(1, _registry.numObjectDefinitions);
		}

		[Test]
		public function testGetObjectDefinition():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			_registry.registerObjectDefinition("test", objectDefinition);
			assertStrictlyEquals(objectDefinition, _registry.getObjectDefinition("test"));
		}

		[Test]
		public function testContainsDefinition():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			assertFalse(_registry.containsObjectDefinition("test"));
			_registry.registerObjectDefinition("test", objectDefinition);
			assertTrue(_registry.containsObjectDefinition("test"));
		}

		[Test]
		public function testIsSingleton():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";
			objectDefinition.isSingleton = true;

			_registry.registerObjectDefinition("test", objectDefinition);
			assertTrue(_registry.isSingleton("test"));
		}

		[Test]
		public function testIsPrototype():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";
			objectDefinition.isSingleton = false;

			_registry.registerObjectDefinition("test", objectDefinition);
			assertTrue(_registry.isPrototype("test"));
		}

		[Test]
		public function testObjectDefinitionNames():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";
			objectDefinition.isSingleton = false;
			_registry.registerObjectDefinition("test", objectDefinition);
			assertEquals("test", _registry.objectDefinitionNames[0]);
		}

		[Test]
		public function testGetType():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			_registry.registerObjectDefinition("test", objectDefinition);
			assertStrictlyEquals(String, _registry.getType("test"));
		}

		[Test]
		public function testGetTypeForNonExistingDefinition():void {
			assertNull(String, _registry.getType("test"));
		}

		[Test]
		public function testGetUsedTypes():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			_registry.registerObjectDefinition("test", objectDefinition);

			objectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			_registry.registerObjectDefinition("test2", objectDefinition);

			assertEquals(1, _registry.getUsedTypes().length);
			assertStrictlyEquals(String, _registry.getUsedTypes()[0]);
		}

		[Test]
		public function testGetObjectNamesForType():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			_registry.registerObjectDefinition("test", objectDefinition);

			objectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			_registry.registerObjectDefinition("test2", objectDefinition);

			assertEquals(2, _registry.getObjectNamesForType(String).length);
			assertStrictlyEquals("test", _registry.getObjectNamesForType(String)[0]);
			assertStrictlyEquals("test2", _registry.getObjectNamesForType(String)[1]);
		}

		[Test]
		public function testGetObjectDefinitionsForType():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			_registry.registerObjectDefinition("test", objectDefinition);

			var objectDefinition2:IObjectDefinition = new ObjectDefinition();
			objectDefinition2.className = "String";

			_registry.registerObjectDefinition("test2", objectDefinition2);

			assertEquals(2, _registry.getObjectDefinitionsForType(String).length);
			assertStrictlyEquals(objectDefinition, _registry.getObjectDefinitionsForType(String)[0]);
			assertStrictlyEquals(objectDefinition2, _registry.getObjectDefinitionsForType(String)[1]);
		}

		[Test]
		public function testGetObjectDefinitionName():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "String";

			_registry.registerObjectDefinition("test", objectDefinition);

			var objectDefinition2:IObjectDefinition = new ObjectDefinition();
			objectDefinition2.className = "String";

			_registry.registerObjectDefinition("test2", objectDefinition2);

			assertEquals("test", _registry.getObjectDefinitionName(objectDefinition));
			assertEquals("test2", _registry.getObjectDefinitionName(objectDefinition2));
		}

		[Test]
		public function testGetObjectDefinitionsWithMetadata():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition();
			objectDefinition.className = "org.springextensions.actionscript.test.testtypes.TestClassWithMetadata";

			_registry.registerObjectDefinition("test", objectDefinition);

			var names:Vector.<String> = new Vector.<String>();
			names.push("Mock");
			var defs:Vector.<IObjectDefinition> = _registry.getObjectDefinitionsWithMetadata(names);
			assertEquals(1, defs.length);
			assertStrictlyEquals(objectDefinition, defs[0]);
		}

	}
}
