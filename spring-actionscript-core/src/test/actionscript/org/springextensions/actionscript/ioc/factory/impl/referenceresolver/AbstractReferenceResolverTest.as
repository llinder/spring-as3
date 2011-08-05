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

	import asmock.framework.SetupResult;
	import asmock.integration.flexunit.IncludeMocksRule;

	import flash.system.ApplicationDomain;

	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.test.AbstractTestWithMockRepository;

	public class AbstractReferenceResolverTest extends AbstractTestWithMockRepository {

		[Rule]
		public var includeMocks:IncludeMocksRule = new IncludeMocksRule([IObjectFactory, IInstanceCache]);

		protected var applicationDomain:ApplicationDomain = ApplicationDomain.currentDomain;
		protected var cache:IInstanceCache;
		protected var factory:IObjectFactory;
		protected var objectDefinitions:Object;

		[Before]
		public function setUp():void {
			objectDefinitions = {};
			cache = IInstanceCache(mockRepository.createStub(IInstanceCache));
			factory = IObjectFactory(mockRepository.createStub(IObjectFactory));
			mockRepository.stubAllProperties(factory);
			SetupResult.forCall(factory.cache).ignoreArguments().returnValue(cache);
			SetupResult.forCall(factory.objectDefinitions).ignoreArguments().returnValue(objectDefinitions);
			factory.applicationDomain = applicationDomain;
		}

		public function AbstractReferenceResolverTest() {
			super();
		}
	}
}
