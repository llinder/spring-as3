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
package org.springextensions.actionscript.context.impl {
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.Timer;

	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.async.operation.OperationEvent;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.hamcrest.core.anything;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;
	import org.springextensions.actionscript.test.testtypes.IAutowireProcessorAwareObjectFactory;
	import org.springextensions.actionscript.test.testtypes.MockDefinitionProviderResultOperation;


	public class ApplicationContextTest {

		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		public var applicationDomain:ApplicationDomain = ApplicationDomain.currentDomain;

		[Mock]
		public var objectFactory:IAutowireProcessorAwareObjectFactory;
		[Mock]
		public var objectDefinitionProvider:IObjectDefinitionsProvider;
		[Mock]
		public var objectDefinitionsRegistry:IObjectDefinitionRegistry;

		/*[Mock]
		public var operation:IOperation;
		[Mock]
		public var objectPostProcessor:IObjectPostProcessor;
		[Mock]
		public var objectFactoryPostProcessor:IObjectFactoryPostProcessor;
		[Mock]
		public var referenceResolver:IReferenceResolver;*/
		private var _context:ApplicationContext;

		public function ApplicationContextTest() {
			super();
		}

		[Test]
		public function testAddDefinitionProvider():void {
			objectFactory = nice(IAutowireProcessorAwareObjectFactory);
			var context:ApplicationContext = new ApplicationContext(null, objectFactory);
			context.addDefinitionProvider(objectDefinitionProvider);
			assertEquals(1, context.definitionProviders.length);
		}

		[Test]
		public function testCompositedMembers():void {
			objectFactory = nice(IAutowireProcessorAwareObjectFactory);
			//objectPostProcessor = nice(IObjectPostProcessor);
			//objectFactoryPostProcessor = nice(IObjectFactoryPostProcessor);
			//referenceResolver = nice(IReferenceResolver);

			mock(objectFactory).method("addObjectFactoryPostProcessor").args(null).once();
			mock(objectFactory).method("addObjectPostProcessor").args(null).once();
			mock(objectFactory).method("addReferenceResolver").args(null).once();
			mock(objectFactory).getter("applicationDomain").returns(applicationDomain).once();
			mock(objectFactory).setter("applicationDomain").arg(applicationDomain).once();
			mock(objectFactory).getter("cache").returns(null).once();
			mock(objectFactory).getter("dependencyInjector").returns(null).once();
			mock(objectFactory).setter("dependencyInjector").arg(null).once();
			stub(objectFactory).method("getObject").args(anything());
			mock(objectFactory).getter("isReady").returns(true).once();
			mock(objectFactory).getter("objectFactoryPostProcessors").returns(null).once();
			mock(objectFactory).getter("objectPostProcessors").returns(null).once();
			mock(objectFactory).getter("parent").returns(null).once();
			mock(objectFactory).getter("propertiesProvider").returns(null).once();
			mock(objectFactory).getter("referenceResolvers").returns(null).once();
			mock(objectFactory).method("resolveReference").args("test").returns(null).once();
			mock(objectFactory).getter("objectDefinitionRegistry").returns(null).once();

			var context:ApplicationContext = new ApplicationContext(null, objectFactory);
			context.addObjectFactoryPostProcessor(null);
			context.addObjectPostProcessor(null);
			context.addReferenceResolver(null);
			var applicationDomain:ApplicationDomain = context.applicationDomain;
			context.applicationDomain = applicationDomain;
			var cache:IInstanceCache = context.cache;
			context.createInstance(String);
			var dependencyInjector:IDependencyInjector = context.dependencyInjector;
			context.dependencyInjector = dependencyInjector;
			context.getObject("testName");
			var b:Boolean = context.isReady;
			var factoryPostProcessors:Vector.<IObjectFactoryPostProcessor> = context.objectFactoryPostProcessors;
			var postProcessors:Vector.<IObjectPostProcessor> = context.objectPostProcessors;
			var parent:IObjectFactory = context.parent;
			var propertiesProvider:IPropertiesProvider = context.propertiesProvider;
			var resolvers:Vector.<IReferenceResolver> = context.referenceResolvers;
			context.resolveReference("test");
			var registry:IObjectDefinitionRegistry = context.objectDefinitionRegistry;

			verify(objectFactory);
		}

		[Test]
		public function testLoadWithSynchronousProvider():void {
			objectDefinitionsRegistry = nice(IObjectDefinitionRegistry);
			var defs:Object = {};
			var def:IObjectDefinition = new ObjectDefinition();
			defs["testName"] = def;
			objectDefinitionProvider = nice(IObjectDefinitionsProvider);
			mock(objectDefinitionProvider).method("createDefinitions").returns(null).once();
			mock(objectDefinitionProvider).getter("objectDefinitions").returns(defs).once();
			stub(objectFactory).getter("objectDefinitionRegistry").returns(objectDefinitionsRegistry);
			stub(objectFactory).method("getObjectDefinition").args("testName").callsWithInvocation(function():IObjectDefinition {
				var result:IObjectDefinition = objectFactory.objectDefinitionRegistry.getObjectDefinition("testName");
				return result;
			}, ["testName"]);
			stub(objectDefinitionsRegistry).getter("objectDefinitions").returns({});
			var reg:Function = function(name:String, def:IObjectDefinition):void {
				mock(objectDefinitionsRegistry).method("getObjectDefinition").args("testName").returns(def);
			};
			stub(objectDefinitionsRegistry).method("registerObjectDefinition").args("testName", def).calls(reg, ["testName", def]);
			mock(objectFactory).setter("isReady").arg(true).once();
			var context:ApplicationContext = new ApplicationContext(null, objectFactory);
			context.addDefinitionProvider(objectDefinitionProvider);
			context.load();
			assertStrictlyEquals(def, context.getObjectDefinition("testName"));
		}

		[Test(async, timeout="1000")]
		public function testLoadWithASynchronousProvider():void {
			objectDefinitionsRegistry = nice(IObjectDefinitionRegistry);
			var defs:Object = {};
			var def:IObjectDefinition = new ObjectDefinition();
			defs["testName"] = def;

			var mockOperation:MockDefinitionProviderResultOperation = new MockDefinitionProviderResultOperation();
			mockOperation.result = defs;
			/*operation = nice(IOperation);
			mock(operation).getter("result").returns(defs);
			mock(operation).method("addCompleteListener").args(anything()).dispatches(new OperationEvent(OperationEvent.COMPLETE, operation), 50);*/
			objectDefinitionProvider = nice(IObjectDefinitionsProvider);
			stub(objectDefinitionProvider).method("createDefinitions").returns(mockOperation).once();
			stub(objectDefinitionProvider).getter("objectDefinitions").returns(defs).once();
			stub(objectFactory).getter("objectDefinitionRegistry").returns(objectDefinitionsRegistry);
			stub(objectFactory).method("getObjectDefinition").args("testName").callsWithInvocation(function():IObjectDefinition {
				var result:IObjectDefinition = objectFactory.objectDefinitionRegistry.getObjectDefinition("testName");
				return result;
			}, ["testName"]);
			stub(objectDefinitionsRegistry).getter("objectDefinitions").returns({});
			var reg:Function = function(name:String, def:IObjectDefinition):void {
				stub(objectDefinitionsRegistry).method("getObjectDefinition").args("testName").returns(def);
			};
			stub(objectDefinitionsRegistry).method("registerObjectDefinition").args("testName", def).calls(reg, ["testName", def]);
			mock(objectFactory).setter("isReady").arg(true).once();

			_context = new ApplicationContext(null, objectFactory);
			_context.addDefinitionProvider(objectDefinitionProvider);
			_context.addEventListener(Event.COMPLETE, Async.asyncHandler(this, handleAsyncProvider, 500, def, handleAsyncProviderTimeOut), false, 0, true);
			_context.load();
			mockOperation.dispatchEvent(new OperationEvent(OperationEvent.COMPLETE, mockOperation));
		}

		protected function handleAsyncProvider(event:Event, passThroughData:Object):void {
			verify(objectFactory);
			assertStrictlyEquals(passThroughData, _context.getObjectDefinition("testName"));
		}

		protected function handleAsyncProviderTimeOut(passThroughData:Object):void {
			verify(objectFactory);
			verify(objectDefinitionProvider);
		}
	}
}
