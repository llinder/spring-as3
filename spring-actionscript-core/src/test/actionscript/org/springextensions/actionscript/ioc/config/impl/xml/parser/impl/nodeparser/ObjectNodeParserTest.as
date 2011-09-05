/*
 * Copyright 2007-2008 the original author or authors.
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
package org.springextensions.actionscript.ioc.config.impl.xml.parser.impl.nodeparser {

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.impl.ApplicationContext;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.impl.XMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory;

	/**
	 * @author Christophe Herreman
	 */
	public class ObjectNodeParserTest {

		public function ObjectNodeParserTest() {
			super();
		}

		[Test]
		public function testParse():void {
			var context:IApplicationContext = new ApplicationContext(null, null, new DefaultObjectFactory());
			var parser:ObjectNodeParser = new ObjectNodeParser(new XMLObjectDefinitionsParser(context));
			var result:Object = parser.parse(<object>
					<property name="key1" value="value1"/>
					<property name="key2" value="35"/>
					<property name="key3" value="false"/>
					<property name="key4">
						<array>
							<value>12</value>
							<value>test</value>
						</array>
					</property>
				</object>);
			assertNotNull(result);
			assertEquals("value1", result.key1);
			assertEquals(35, result.key2);
			assertEquals(false, result.key3);
			assertNotNull(result.key4);
			assertEquals(2, result.key4.length);
		}

	}
}
