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
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.springextensions.actionscript.ioc.autowire.AutowireMode;
	import org.springextensions.actionscript.ioc.objectdefinition.ChildContextObjectDefinitionAccess;
	import org.springextensions.actionscript.ioc.objectdefinition.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.objectdefinition.ObjectDefinitionScope;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class MXMLObjectDefinitionTest {

		public function MXMLObjectDefinitionTest() {
			super();
		}

		private var _definition:MXMLObjectDefinition;

		[Before]
		public function setUp():void {
			_definition = new MXMLObjectDefinition();
		}

		[Test]
		public function testAutoWireMode():void {
			_definition.autoWireMode = AutowireMode.BYTYPE.name;
			assertStrictlyEquals(AutowireMode.BYTYPE, _definition.definition.autoWireMode);
		}

		[Test]
		public function testChildContextAccess():void {
			_definition.childContextAccess = ChildContextObjectDefinitionAccess.SINGLETON.value;
			assertStrictlyEquals(ChildContextObjectDefinitionAccess.SINGLETON, _definition.definition.childContextAccess);
		}

		[Test]
		public function testClassName():void {
			_definition.className = "org.springextensions.actionscript.ioc.autowire.AutowireMode";
			assertEquals("org.springextensions.actionscript.ioc.autowire.AutowireMode", _definition.definition.className);
			assertStrictlyEquals(AutowireMode, _definition.definition.clazz);
		}

		[Test]
		public function testClazz():void {
			_definition.clazz = AutowireMode;
			assertStrictlyEquals(AutowireMode, _definition.definition.clazz);
			assertEquals("org.springextensions.actionscript.ioc.autowire.AutowireMode", _definition.definition.className);
		}

		[Test]
		public function testDependencyCheck():void {
			_definition.dependencyCheck = DependencyCheckMode.OBJECTS.name;
			assertStrictlyEquals(DependencyCheckMode.OBJECTS, _definition.definition.dependencyCheck);
		}

		[Test]
		public function testDependsOn():void {
			var mod:MXMLObjectDefinition = new MXMLObjectDefinition();
			mod.id = "test";
			var vec:Vector.<MXMLObjectDefinition> = new Vector.<MXMLObjectDefinition>();
			vec[vec.length] = mod;
			_definition.dependsOn = vec;
			assertNotNull(_definition.definition.dependsOn);
			assertEquals(1, _definition.definition.dependsOn.length);
			assertEquals("test", _definition.definition.dependsOn[0]);
		}

		[Test]
		public function testDestroyMethod():void {
			_definition.destroyMethod = "dispose";
			assertEquals("dispose", _definition.definition.destroyMethod);
		}

		[Test]
		public function testFactoryMethod():void {
			_definition.factoryMethod = "newInstance";
			assertEquals("newInstance", _definition.definition.factoryMethod);
		}

		[Test]
		public function testFactoryObjectName():void {
			_definition.factoryObjectName = "factoryName";
			assertEquals("factoryName", _definition.definition.factoryObjectName);
		}

		[Test]
		public function testInitMethod():void {
			_definition.initMethod = "init";
			assertEquals("init", _definition.definition.initMethod);
		}

		[Test]
		public function testIsAbstract():void {
			_definition.isAbstract = true;
			assertEquals(true, _definition.definition.isAbstract);
		}

		[Test]
		public function testIsAutoWireCandidate():void {
			_definition.isAutoWireCandidate = false;
			assertEquals(false, _definition.definition.isAutoWireCandidate);
		}

		/*[Test]
		public function testIsInterface():void {
			_definition. = ;
			assertEquals(, _definition.definition.);
		}*/
		[Test]
		public function testIsLazyInit():void {
			_definition.isLazyInit = true;
			assertEquals(true, _definition.definition.isLazyInit);
		}

		[Test]
		public function testIsSingleton():void {
			_definition.isSingleton = false;
			assertEquals(false, _definition.definition.isSingleton);
			assertStrictlyEquals(ObjectDefinitionScope.PROTOTYPE, _definition.definition.scope);
		}

		[Test]
		public function testParent():void {
			var mod:MXMLObjectDefinition = new MXMLObjectDefinition();
			mod.id = "test";
			_definition.parentObject = mod;
			assertStrictlyEquals(mod.definition, _definition.definition.parent);
			assertStrictlyEquals(mod.id, _definition.definition.parentName);
		}

		[Test]
		public function testPrimary():void {
			_definition.primary = true;
			assertEquals(true, _definition.definition.primary);
		}

		[Test]
		public function testScope():void {
			_definition.scope = ObjectDefinitionScope.PROTOTYPE.name;
			assertStrictlyEquals(ObjectDefinitionScope.PROTOTYPE, _definition.definition.scope);
		}

		[Test]
		public function testSkipMetadata():void {
			_definition.skipMetadata = true;
			assertEquals(true, _definition.definition.skipMetadata);
		}

		[Test]
		public function testSkipPostProcessors():void {
			_definition.skipPostProcessors = true;
			assertEquals(true, _definition.definition.skipPostProcessors);
		}
	}
}
