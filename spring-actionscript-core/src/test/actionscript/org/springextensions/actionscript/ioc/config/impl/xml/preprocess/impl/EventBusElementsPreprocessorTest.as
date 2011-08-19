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
package org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl {
	import org.flexunit.asserts.assertEquals;


	public class EventBusElementsPreprocessorTest {

		private var testXML:XML = new XML('<objects xmlns="http://www.springactionscript.org/schema/objects"' + //
			'xmlns:eventbus="http://www.springactionscript.org/schema/eventbus"' + //
			'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' + //
			'xsi:schemaLocation="http://www.springactionscript.org/schema/objects http://www.springactionscript.org/schema/objects/spring-actionscript-objects-2.0.xsd ' + //
			'http://www.springactionscript.org/schema/objects http://www.springactionscript.org/schema/objects/spring-actionscript-eventbus-2.0.xsd">' + //
			'<eventbus:event-handler id="handler1"/>' + //
			'<object id="test1" class="Object"/>' + //
			'<object id="test2" class="Object"/>' + //
			'<eventbus:event-handler id="handler2"/>' + //
			'<object id="test3" class="Object"/>' + //
			'<object id="test4" class="Object"/>' + //
			'<object id="test5" class="Object"/>' + //
			'<object id="test6" class="Object"/>' + //
			'<eventbus:event-handler id="handler3"/>' + //
			'<eventbus:event-handler id="handler4"/>' + //
			'<object id="test7" class="Object"/>' + //
			'<object id="test8" class="Object"/>' + //
			'</objects>');

		public function EventBusElementsPreprocessorTest() {
			super();
		}

		[Test]
		public function testPreprocess():void {
			var preprocessor:EventBusElementsPreprocessor = new EventBusElementsPreprocessor();
			var xml:XML = preprocessor.preprocess(testXML);
			assertEquals('handler1', String(xml.children()[8].@id));
			assertEquals('handler2', String(xml.children()[9].@id));
			assertEquals('handler3', String(xml.children()[10].@id));
			assertEquals('handler4', String(xml.children()[11].@id));
		}
	}
}
