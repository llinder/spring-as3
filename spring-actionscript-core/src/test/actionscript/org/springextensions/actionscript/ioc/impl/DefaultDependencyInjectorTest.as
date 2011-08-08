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
package org.springextensions.actionscript.ioc.impl {

	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;
	import mockolate.verify;

	import org.hamcrest.core.anything;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessor;
	import org.springextensions.actionscript.ioc.factory.IInitializingObject;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.test.testtypes.AutowiredAnnotatedClass;
	import org.springextensions.actionscript.test.testtypes.IAutowireProcessorAwareObjectFactory;

	public class DefaultDependencyInjectorTest {

		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		public function DefaultDependencyInjectorTest() {
			super();
		}

		public var injector:DefaultDependencyInjector;
		[Mock]
		public var cache:IInstanceCache;
		[Mock]
		public var processor:IObjectPostProcessor;
		[Mock]
		public var resolver:IReferenceResolver;
		[Mock]
		public var factory:IAutowireProcessorAwareObjectFactory;
		[Mock]
		public var initializingObject:IInitializingObject;
		[Mock]
		public var autowireProcessor:IAutowireProcessor;

		[Before]
		public function setUp():void {
			injector = new DefaultDependencyInjector();
			cache = nice(IInstanceCache);
			processor = nice(IObjectPostProcessor);
			resolver = nice(IReferenceResolver);
			factory = nice(IAutowireProcessorAwareObjectFactory);
		}

		[Test]
		public function testWireWithoutDefinition():void {
			var instance:AutowiredAnnotatedClass = new AutowiredAnnotatedClass();
			var autowire:IAutowireProcessor = nice(IAutowireProcessor);
			stub(autowire).method("autoWire").args(anything());
			mock(factory).getter("autowireProcessor").returns(autowire);
			injector.wire(instance, factory);
			verify(factory);
			verify(autowire);
		}

		[Test]
		public function testWireWithoutDefinitionAndWithObjectPostProcessor():void {
			var instance:AutowiredAnnotatedClass = new AutowiredAnnotatedClass();
			var autowire:IAutowireProcessor = nice(IAutowireProcessor);
			stub(autowire).method("autoWire").args(anything()).once();
			stub(processor).method("postProcessBeforeInitialization").args(anything()).returns(instance).once();
			stub(processor).method("postProcessAfterInitialization").args(anything()).returns(instance).once();
			mock(factory).getter("autowireProcessor").returns(autowire);
			var procs:Vector.<IObjectPostProcessor> = new Vector.<IObjectPostProcessor>();
			procs.push(IObjectPostProcessor(processor));
			mock(factory).getter("objectPostProcessors").returns(procs);

			injector.wire(instance, factory);
			verify(factory);
		}

		[Test]
		public function testWireWithoutDefinitionAndWithInitializingObject():void {
			initializingObject = nice(IInitializingObject);
			mock(initializingObject).method("afterPropertiesSet").once();
			injector.wire(initializingObject, factory);
			verify(initializingObject);
		}
	}
}
