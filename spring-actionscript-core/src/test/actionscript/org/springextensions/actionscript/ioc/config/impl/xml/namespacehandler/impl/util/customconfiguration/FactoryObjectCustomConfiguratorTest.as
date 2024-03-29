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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.util.customconfiguration {
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.springextensions.actionscript.ioc.factory.impl.GenericFactoryObject;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class FactoryObjectCustomConfiguratorTest {
		/**
		 * Creates a new <code>FactoryObjectCustomConfiguratorTest</code> instance.
		 */
		public function FactoryObjectCustomConfiguratorTest() {
			super();
		}

		[Test]
		public function testExecute():void {
			var definition:ObjectDefinition = new ObjectDefinition();
			definition.isSingleton = false;
			var instance:Object = {};
			var config:FactoryObjectCustomConfigurator = new FactoryObjectCustomConfigurator("methodName");
			assertEquals("methodName", config.factoryMethod);
			var result:* = config.execute(instance, definition);
			assertTrue(result is GenericFactoryObject);
			var gfo:GenericFactoryObject = GenericFactoryObject(result);
			assertEquals(gfo.isSingleton, definition.isSingleton);
		}
	}
}
