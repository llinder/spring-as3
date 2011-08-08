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
package org.springextensions.actionscript.ioc.factory.impl {
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3commons.eventbus.IEventBus;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.core.anything;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.config.impl.RuntimeObjectReference;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;
	import org.springextensions.actionscript.ioc.spring_actionscript_internal;
	import org.springextensions.actionscript.test.testtypes.ClassWithStaticFactoryMethod;
	import org.springextensions.actionscript.test.testtypes.TestClassFactory;



	public class DefaultObjectFactoryTest {

		{
			ClassWithStaticFactoryMethod;
			TestClassFactory;
		}

		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock]
		public var objectPostProcessor:IObjectPostProcessor;
		[Mock]
		public var objectFactoryPostProcessor:IObjectFactoryPostProcessor;
		[Mock]
		public var cache:IInstanceCache;
		[Mock]
		public var injector:IDependencyInjector;
		[Mock]
		public var eventBus:IEventBus;

		private var _objectFactory:DefaultObjectFactory;

		public function DefaultObjectFactoryTest() {
			super();
		}

		[Before]
		public function setUp():void {
			_objectFactory = new DefaultObjectFactory();
			_objectFactory.cache = nice(IInstanceCache);
			_objectFactory.spring_actionscript_internal::setIsReady(true);
		}

		[Test]
		public function testAddObjectPostProcessor():void {
			var processor:IObjectPostProcessor = nice(IObjectPostProcessor);
			assertEquals(0, _objectFactory.objectPostProcessors.length);
			_objectFactory.addObjectPostProcessor(processor);
			assertEquals(1, _objectFactory.objectPostProcessors.length);
		}

		[Test]
		public function testAddObjectFactoryPostProcessor():void {
			var processor:IObjectFactoryPostProcessor = nice(IObjectFactoryPostProcessor);
			assertEquals(0, _objectFactory.objectFactoryPostProcessors.length);
			_objectFactory.addObjectFactoryPostProcessor(processor);
			assertEquals(1, _objectFactory.objectFactoryPostProcessors.length);
		}

		[Test(expects = "org.springextensions.actionscript.ioc.objectdefinition.error.ObjectDefinitionNotFoundError")]
		public function testgetObjectWithMissingDefinition():void {
			mock(_objectFactory.cache).method("isPrepared").returns(false).twice();
			mock(_objectFactory.cache).method("hasInstance").returns(false).once();
			_objectFactory.getObject("testName");
		}

		[Test]
		public function testgetObjectWithSimpleDefinition():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition("int");
			mock(_objectFactory.cache).method("isPrepared").returns(false).twice();
			mock(_objectFactory.cache).method("hasInstance").returns(false).once();
			_objectFactory.objectDefinitions["testName"] = objectDefinition;
			var result:int = _objectFactory.getObject("testName");
			verify(cache);
			assertEquals(0, result);
		}

		[Test]
		public function testgetObjectWithSimpleDefinitionWithConstructorArgument():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition("String");
			objectDefinition.constructorArguments = ["test"];
			mock(_objectFactory.cache).method("isPrepared").returns(false).twice();
			mock(_objectFactory.cache).method("hasInstance").returns(false).once();
			_objectFactory.objectDefinitions["testName"] = objectDefinition;
			var result:String = _objectFactory.getObject("testName");
			verify(cache);
			assertEquals("test", result);
		}

		[Test]
		public function testgetObjectWithSimpleDefinitionWithConstructorArgumentAndDependencyInjectionVerification():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition("String");
			objectDefinition.constructorArguments = ["test"];
			mock(_objectFactory.cache).method("isPrepared").returns(false).twice();
			mock(_objectFactory.cache).method("hasInstance").returns(false).once();
			_objectFactory.objectDefinitions["testName"] = objectDefinition;
			_objectFactory.dependencyInjector = nice(IDependencyInjector);
			stub(_objectFactory.dependencyInjector).method("wire").args(anything()).once();
			var result:String = _objectFactory.getObject("testName");
			verify(cache);
			assertEquals("test", result);
		}

		[Test]
		public function testCreateInstance():void {
			var result:String = _objectFactory.createInstance(String, ["test"]);
			assertEquals("test", result);
		}

		[Test]
		public function testgetObjectWithEventBusDispatch():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition("int");
			mock(_objectFactory.cache).method("isPrepared").returns(false).twice();
			mock(_objectFactory.cache).method("hasInstance").returns(false).once();
			_objectFactory.objectDefinitions["testName"] = objectDefinition;
			_objectFactory.eventBus = nice(IEventBus);
			mock(_objectFactory.eventBus).method("dispatchEvent").args(anything());
			var result:int = _objectFactory.getObject("testName");
			verify(cache);
			verify(_objectFactory.eventBus);
			assertEquals(0, result);
		}

		[Test]
		public function testgetObjectWithStaticFactoryMethod():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition("org.springextensions.actionscript.test.testtypes.ClassWithStaticFactoryMethod");
			objectDefinition.factoryMethod = "newInstance";
			mock(_objectFactory.cache).method("isPrepared").returns(false).twice();
			mock(_objectFactory.cache).method("hasInstance").returns(false).once();
			_objectFactory.objectDefinitions["testName"] = objectDefinition;
			var result:ClassWithStaticFactoryMethod = _objectFactory.getObject("testName");
			verify(cache);
			assertNotNull(result);
			assertTrue(result.createdByStaticMethod);
		}

		[Test]
		public function testgetObjectWithFactoryObjectName():void {
			var objectDefinition:IObjectDefinition = new ObjectDefinition("org.springextensions.actionscript.test.testtypes.ClassWithStaticFactoryMethod");
			objectDefinition.factoryMethod = "newInstance";
			objectDefinition.factoryObjectName = "factoryObject";
			mock(_objectFactory.cache).method("isPrepared").returns(false).twice();
			mock(_objectFactory.cache).method("hasInstance").returns(false).once();
			_objectFactory.objectDefinitions["testName"] = objectDefinition;
			objectDefinition = new ObjectDefinition("org.springextensions.actionscript.test.testtypes.TestClassFactory");
			_objectFactory.objectDefinitions["factoryObject"] = objectDefinition;
			var result:ClassWithStaticFactoryMethod = _objectFactory.getObject("testName");
			verify(cache);
			assertNotNull(result);
			assertFalse(result.createdByStaticMethod);
		}

	}
}
