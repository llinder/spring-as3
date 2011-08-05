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

	import asmock.framework.Expect;
	import asmock.framework.SetupResult;
	import asmock.integration.flexunit.IncludeMocksRule;

	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessor;
	import org.springextensions.actionscript.ioc.factory.IInitializingObject;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.test.AbstractTestWithMockRepository;
	import org.springextensions.actionscript.test.testtypes.AutowiredAnnotatedClass;

	public class DefaultDependencyInjectorTest extends AbstractTestWithMockRepository {

		[Rule]
		public var includeMockRule:IncludeMocksRule = new IncludeMocksRule([IAutowireProcessor, IObjectPostProcessor, IReferenceResolver, IInstanceCache, IInitializingObject, IObjectFactory]);

		public function DefaultDependencyInjectorTest() {
			super();
		}

		private var _injector:DefaultDependencyInjector;
		private var _cache:IInstanceCache;
		private var _processor:IObjectPostProcessor;
		private var _resolver:IReferenceResolver;
		private var _factory:IObjectFactory;

		[Before]
		public function setUp():void {
			_injector = new DefaultDependencyInjector();
			_cache = IInstanceCache(mockRepository.createStub(IInstanceCache));
			_processor = IObjectPostProcessor(mockRepository.createStub(IObjectPostProcessor));
			_resolver = IReferenceResolver(mockRepository.createStub(IReferenceResolver));
			_factory = IObjectFactory(mockRepository.createStub(IObjectFactory));
			//	_factory.
		}

		[Test]
		public function testWireWithoutDefinition():void {
			var instance:AutowiredAnnotatedClass = new AutowiredAnnotatedClass();
			var autowire:IAutowireProcessor = IAutowireProcessor(mockRepository.create(IAutowireProcessor));
			Expect.call(autowire.autoWire(instance)).ignoreArguments();
			//SetupResult.forCall(_factory.
			mockRepository.replayAll();

			//_injector.autowireProcessor = autowire;
			_injector.wire(instance, _factory);
			mockRepository.verifyAll();
		}

		[Test]
		public function testWireWithoutDefinitionAndWithObjectPostProcessor():void {
			var instance:AutowiredAnnotatedClass = new AutowiredAnnotatedClass();
			var autowire:IAutowireProcessor = IAutowireProcessor(mockRepository.create(IAutowireProcessor));
			Expect.call(autowire.autoWire(instance)).ignoreArguments();
			Expect.call(_processor.postProcessAfterInitialization(null, null)).ignoreArguments().returnValue(null).repeat.once();
			Expect.call(_processor.postProcessBeforeInitialization(null, null)).ignoreArguments().returnValue(null).repeat.once();

			mockRepository.replayAll();

			var procs:Vector.<IObjectPostProcessor> = new Vector.<IObjectPostProcessor>();
			procs.push(_processor);

			//_injector.autowireProcessor = autowire;
			//_injector.wire(instance, _cache, null, null, procs);
			mockRepository.verifyAll();
		}

		[Test]
		public function testWireWithoutDefinitionAndWithInitializingObject():void {
			var initializing:IInitializingObject = IInitializingObject(mockRepository.create(IInitializingObject));
			Expect.call(initializing.afterPropertiesSet()).ignoreArguments().repeat.once();

			mockRepository.replayAll();
			//_injector.wire(initializing,);
			mockRepository.verifyAll();
		}
	}
}
