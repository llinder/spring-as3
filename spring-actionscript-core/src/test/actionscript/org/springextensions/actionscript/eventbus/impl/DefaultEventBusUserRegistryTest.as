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
package org.springextensions.actionscript.eventbus.impl {
	import flash.events.Event;

	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.verify;

	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.eventbus.IEventInterceptor;
	import org.as3commons.eventbus.IEventListenerInterceptor;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultEventBusUserRegistryTest {

		private var _registry:DefaultEventBusUserRegistry;

		[Rule]
		public var mockolateRule:MockolateRule = new MockolateRule();

		[Mock]
		public var eventBus:IEventBus;
		[Mock]
		public var eventInterceptor:IEventInterceptor;
		[Mock]
		public var eventListenerInterceptor:IEventListenerInterceptor;

		/**
		 * Creates a new <code>DefaultEventBusUserRegistryTest</code> instance.
		 */
		public function DefaultEventBusUserRegistryTest() {
			super();
		}

		[Before]
		public function setUp():void {
			eventBus = nice(IEventBus);
			_registry = new DefaultEventBusUserRegistry(eventBus);
			assertStrictlyEquals(eventBus, _registry.eventBus);
		}

		[Test]
		public function testAddEventClassInterceptorWithoutTopic():void {
			eventInterceptor = nice(IEventInterceptor);
			mock(eventBus).method("addEventClassInterceptor").args(Event, eventInterceptor, null).once();
			_registry.addEventClassInterceptor(Event, eventInterceptor);
			verify(eventBus);
			var entry:EventBusRegistryEntry = _registry.eventBusRegistryEntryCache[eventInterceptor];
			assertNotNull(entry);
			assertEquals(0, entry.eventTypeEntries.length);
			assertEquals(1, entry.classEntries.length);
			assertStrictlyEquals(Event, entry.classEntries[0].clazz);
			assertNull(entry.classEntries[0].topic);
		}

		[Test]
		public function testAddEventClassInterceptorWithTopic():void {
			var topic:Object = {};
			eventInterceptor = nice(IEventInterceptor);
			mock(eventBus).method("addEventClassInterceptor").args(Event, eventInterceptor, topic).once();
			_registry.addEventClassInterceptor(Event, eventInterceptor, topic);
			verify(eventBus);
			var entry:EventBusRegistryEntry = _registry.eventBusRegistryEntryCache[eventInterceptor];
			assertNotNull(entry);
			assertEquals(0, entry.eventTypeEntries.length);
			assertEquals(1, entry.classEntries.length);
			assertStrictlyEquals(Event, entry.classEntries[0].clazz);
			assertStrictlyEquals(topic, entry.classEntries[0].topic);
		}

		[Test]
		public function testAddEventClassListenerInterceptorWithoutTopic():void {
			eventListenerInterceptor = nice(IEventListenerInterceptor);
			mock(eventBus).method("addEventClassListenerInterceptor").args(Event, eventListenerInterceptor, null).once();
			_registry.addEventClassListenerInterceptor(Event, eventListenerInterceptor);
			verify(eventBus);
			var entry:EventBusRegistryEntry = _registry.eventBusRegistryEntryCache[eventListenerInterceptor];
			assertNotNull(entry);
			assertEquals(0, entry.eventTypeEntries.length);
			assertEquals(1, entry.classEntries.length);
			assertStrictlyEquals(Event, entry.classEntries[0].clazz);
			assertNull(entry.classEntries[0].topic);
		}

		[Test]
		public function testAddEventClassListenerInterceptorWithTopic():void {
			var topic:Object = {};
			eventListenerInterceptor = nice(IEventListenerInterceptor);
			mock(eventBus).method("addEventClassListenerInterceptor").args(Event, eventListenerInterceptor, topic).once();
			_registry.addEventClassListenerInterceptor(Event, eventListenerInterceptor, topic);
			verify(eventBus);
			var entry:EventBusRegistryEntry = _registry.eventBusRegistryEntryCache[eventListenerInterceptor];
			assertNotNull(entry);
			assertEquals(0, entry.eventTypeEntries.length);
			assertEquals(1, entry.classEntries.length);
			assertStrictlyEquals(Event, entry.classEntries[0].clazz);
			assertStrictlyEquals(topic, entry.classEntries[0].topic);
		}

	}
}
