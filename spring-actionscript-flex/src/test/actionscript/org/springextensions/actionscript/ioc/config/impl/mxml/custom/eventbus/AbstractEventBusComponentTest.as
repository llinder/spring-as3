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
package org.springextensions.actionscript.ioc.config.impl.mxml.custom.eventbus {
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class AbstractEventBusComponentTest {

		[Rule]
		public var mockolateRule:MockolateRule = new MockolateRule();

		[Mock]
		public var objectDefinitionRegistry:IObjectDefinitionRegistry;
		[Mock]
		public var configurator:ICustomConfigurator;

		private var _component:AbstractEventBusComponent;

		/**
		 * Creates a new <code>AbstractEventBusComponentTest</code> instance.
		 */
		public function AbstractEventBusComponentTest() {
			super();
		}

		[Before]
		public function setUp():void {
			_component = new AbstractEventBusComponent();
			objectDefinitionRegistry = nice(IObjectDefinitionRegistry);
			configurator = nice(ICustomConfigurator);
		}

		[Test]
		public function testgetCustomConfigurationForObjectNameWithNullReturning():void {
			mock(objectDefinitionRegistry).method("getCustomConfiguration").args("test").returns(null).once();
			var vec:Vector.<ICustomConfigurator> = _component.getCustomConfigurationForObjectName("test", objectDefinitionRegistry);
			assertNotNull(vec);
			assertEquals(0, vec.length);
		}

		[Test]
		public function testgetCustomConfigurationForObjectNameWithIConfiguratorReturning():void {
			mock(objectDefinitionRegistry).method("getCustomConfiguration").args("test").returns(configurator).once();
			var vec:Vector.<ICustomConfigurator> = _component.getCustomConfigurationForObjectName("test", objectDefinitionRegistry);
			assertNotNull(vec);
			assertEquals(1, vec.length);
			assertStrictlyEquals(configurator, vec[0]);
		}

		[Test]
		public function testgetCustomConfigurationForObjectNameWithVectorReturning():void {
			var vec1:Vector.<ICustomConfigurator> = new Vector.<ICustomConfigurator>();
			mock(objectDefinitionRegistry).method("getCustomConfiguration").args("test").returns(vec1).once();
			var vec2:Vector.<ICustomConfigurator> = _component.getCustomConfigurationForObjectName("test", objectDefinitionRegistry);
			assertNotNull(vec2);
			assertEquals(0, vec2.length);
			assertStrictlyEquals(vec1, vec2);
		}
	}
}
