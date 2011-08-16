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
package integration.objectfactory {
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_objects;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultInstanceCache;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory;
	import org.springextensions.actionscript.ioc.impl.DefaultDependencyInjector;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.DefaultObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;
	import org.springextensions.actionscript.test.testtypes.TestInjectionClass;


	public class ObjectFactoryIntegrationTest {

		public function ObjectFactoryIntegrationTest() {
			super();
		}

		[Test]
		public function testGetObject():void {
			var objectFactory:DefaultObjectFactory = new DefaultObjectFactory();
			objectFactory.isReady = true;
			objectFactory.cache = new DefaultInstanceCache();
			objectFactory.objectDefinitionRegistry = new DefaultObjectDefinitionRegistry();
			objectFactory.dependencyInjector = new DefaultDependencyInjector();
			var definition:IObjectDefinition = new ObjectDefinition("org.springextensions.actionscript.test.testtypes.TestInjectionClass");
			definition.addPropertyDefinition(new PropertyDefinition("testProperty", "testValue"));
			definition.addPropertyDefinition(new PropertyDefinition("testProperty", "testValue2", spring_actionscript_objects));
			definition.addPropertyDefinition(new PropertyDefinition("testStaticProperty", "testValue3", null, true));
			definition.addMethodInvocation(new MethodInvocation("testCounter"));
			definition.addMethodInvocation(new MethodInvocation("testCounter", null, spring_actionscript_objects));
			objectFactory.objectDefinitionRegistry.registerObjectDefinition("test", definition);
			var result:TestInjectionClass = objectFactory.getObject("test");
			assertNotNull(result);
			assertEquals("testValue", result.testProperty);
			assertEquals("testValue2", result.spring_actionscript_objects::testProperty);
			assertEquals("testValue3", TestInjectionClass.testStaticProperty);
			assertEquals(3, result.count);
			assertEquals(1, objectFactory.cache.numInstances());
			assertEquals("test", objectFactory.cache.getCachedNames()[0]);
		}
	}
}
