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
package org.springextensions.actionscript.ioc.factory.process.impl.factory {
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.hamcrest.core.anything;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class ObjectDefinitonFactoryPostProcessorTest {

		[Rule]
		public var mockolateRule:MockolateRule = new MockolateRule();

		[Mock]
		public var registry:IObjectDefinitionRegistry;
		[Mock]
		public var objectDefinition:IObjectDefinition;
		public var parentDefinition:IObjectDefinition;

		private var _processor:ObjectDefinitonFactoryPostProcessor;

		public function ObjectDefinitonFactoryPostProcessorTest() {
			super();
		}

		[Before]
		public function setUp():void {
			registry = nice(IObjectDefinitionRegistry);
			objectDefinition = nice(IObjectDefinition);
			parentDefinition = nice(IObjectDefinition);
			stub(objectDefinition).getter("parent").returns(parentDefinition);
			_processor = new ObjectDefinitonFactoryPostProcessor(1);
		}

		[Test]
		public function testCopyConstructorArgumentsWithAllNullArgs():void {
			mock(objectDefinition).getter("constructorArguments").returns(null);
			mock(parentDefinition).getter("constructorArguments").returns(null);
			mock(objectDefinition).setter("constructorArguments").never();
			_processor.copyConstructorArguments(objectDefinition, parentDefinition);
		}

		[Test]
		public function testCopyConstructorArgumentsWitAllNotnUllArgs():void {
			mock(objectDefinition).getter("constructorArguments").returns([]);
			mock(parentDefinition).getter("constructorArguments").returns([]);
			mock(objectDefinition).setter("constructorArguments").never();
			_processor.copyConstructorArguments(objectDefinition, parentDefinition);
		}

		[Test]
		public function testCopyConstructorArgumentsWitParentNotnUllArgs():void {
			var args:Array = [];
			mock(objectDefinition).getter("constructorArguments").returns(null);
			mock(parentDefinition).getter("constructorArguments").returns(args);
			mock(objectDefinition).setter("constructorArguments").arg(args).once();
			_processor.copyConstructorArguments(objectDefinition, parentDefinition);
		}
	}
}
