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

	import org.as3commons.lang.IDisposable;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;

	public class DefaultInstanceCacheTest {

		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock]
		public var disposable:IDisposable;

		private var _cache:DefaultInstanceCache;

		public function DefaultInstanceCacheTest() {
			super();
		}

		[Before]
		public function setUp():void {
			_cache = new DefaultInstanceCache();
		}

		[Test]
		public function testAddInstance():void {
			assertEquals(0, _cache.numInstances());
			_cache.addInstance("test", {});
			assertEquals(1, _cache.numInstances());
			_cache.addInstance("test", {});
			assertEquals(1, _cache.numInstances());
			_cache.addInstance("test2", {});
			assertEquals(2, _cache.numInstances());
		}

		[Test]
		public function testRemoveInstance():void {
			assertEquals(0, _cache.numInstances());
			var obj:Object = {};
			_cache.addInstance("test", obj);
			assertEquals(1, _cache.numInstances());
			assertStrictlyEquals(obj, _cache.removeInstance("test"));
			assertEquals(0, _cache.numInstances());
		}

		[Test]
		public function testHasInstance():void {
			_cache.addInstance("test", {});
			assertTrue(_cache.hasInstance("test"));
			assertFalse(_cache.hasInstance("test2"));
		}

		[Test]
		public function testGetInstance():void {
			var instance:Object = {};
			_cache.addInstance("test", instance);
			var instance2:Object = _cache.getInstance("test");
			assertStrictlyEquals(instance, instance2);

			instance = {};
			_cache.addInstance("test2", instance);
			instance2 = _cache.getInstance("test2");
			assertStrictlyEquals(instance, instance2);
		}

		[Test(expects="org.springextensions.actionscript.ioc.objectdefinition.error.ObjectDefinitionNotFoundError")]
		public function testGetInstanceForUnknownInstance():void {
			_cache.getInstance("test");
		}

		[Test]
		public function testClearCache():void {
			_cache.addInstance("test", {});
			_cache.addInstance("test2", {});

			assertEquals(2, _cache.numInstances());

			_cache.clearCache();
			assertEquals(0, _cache.numInstances());
		}

		[Test]
		public function testClearCacheWithIDisposableImplementation():void {
			disposable = nice(IDisposable);
			stub(disposable).getter("isDisposed").returns(false);
			stub(disposable).method("dispose").once();

			_cache.addInstance("test", disposable);
			_cache.clearCache();

			//verify(disposable);
		}

		[Test]
		public function testIsPreparedWithObjectThatIsNotPrepared():void {
			var result:Boolean = _cache.isPrepared("test");
			assertFalse(result);
		}

		[Test]
		public function testIsPreparedWithObjectThatIsPrepared():void {
			var obj:Object = {};
			_cache.prepareInstance("test", obj);
			var result:Boolean = _cache.isPrepared("test");
			assertTrue(result);
		}

		[Test]
		public function testPreparedObjectIsRemovedFromPreparedCacheAfterAddInstance():void {
			var obj:Object = {};
			_cache.prepareInstance("test", obj);
			_cache.addInstance("test", obj);
			var result:Boolean = _cache.isPrepared("test");
			assertFalse(result);
		}

	}
}
