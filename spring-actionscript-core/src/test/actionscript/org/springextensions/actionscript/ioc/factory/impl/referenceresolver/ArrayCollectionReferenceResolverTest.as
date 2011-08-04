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
package org.springextensions.actionscript.ioc.factory.impl.referenceresolver {
	import asmock.framework.Expect;
	import asmock.framework.SetupResult;
	import asmock.integration.flexunit.IncludeMocksRule;

	import flash.system.ApplicationDomain;

	import mx.collections.ArrayCollection;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.test.AbstractTestWithMockRepository;

	public class ArrayCollectionReferenceResolverTest extends AbstractTestWithMockRepository {

		[Rule]
		public var includeMocks:IncludeMocksRule = new IncludeMocksRule([IObjectFactory, IInstanceCache]);

		private var _applicationDomain:ApplicationDomain = ApplicationDomain.currentDomain;
		private var _cache:IInstanceCache;
		private var _factory:IObjectFactory;
		private var _objectDefinitions:Object;

		public function ArrayCollectionReferenceResolverTest() {
			super();
		}

		[Before]
		public function setUp():void {
			_objectDefinitions = {};
			_cache = IInstanceCache(mockRepository.createStub(IInstanceCache));
			_factory = IObjectFactory(mockRepository.createStub(IObjectFactory));
			mockRepository.stubAllProperties(_factory);
			SetupResult.forCall(_factory.cache).ignoreArguments().returnValue(_cache);
			SetupResult.forCall(_factory.objectDefinitions).ignoreArguments().returnValue(_objectDefinitions);
			_factory.applicationDomain = _applicationDomain;
		}

		[Test]
		public function testCanResolveWithArrayCollection():void {
			mockRepository.replayAll();
			var resolver:ArrayCollectionReferenceResolver = new ArrayCollectionReferenceResolver(_factory);
			var result:Boolean = resolver.canResolve(new ArrayCollection());
			assertTrue(result);
		}

		[Test]
		public function testCanResolveWithArray():void {
			mockRepository.replayAll();
			var resolver:ArrayCollectionReferenceResolver = new ArrayCollectionReferenceResolver(_factory);
			var result:Boolean = resolver.canResolve([]);
			assertFalse(result);
		}

		[Test]
		public function testCanCreate():void {
			var result:Boolean = ArrayCollectionReferenceResolver.canCreate(_applicationDomain);
			assertTrue(result);
		}

		[Test]
		public function testResolve():void {
			Expect.call(_factory.resolveReference("testProperty")).returnValue("resolved");
			mockRepository.replayAll();

			var col:ArrayCollection = new ArrayCollection(["testProperty"]);
			var resolver:ArrayCollectionReferenceResolver = new ArrayCollectionReferenceResolver(_factory);

			col = resolver.resolve(col) as ArrayCollection;
			mockRepository.verifyAll();
			assertEquals("resolved", col.getItemAt(0));
		}
	}
}
