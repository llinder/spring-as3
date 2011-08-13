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
package org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl {
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	/**
	 * @author Christophe Herreman
	 */
	public class ParentAttributePreprocessorTest {

		public function ParentAttributePreprocessorTest() {
			super();
		}

		[Test]
		public function testPreprocess_shouldNotInsertAbstractAttributeInChildObject():void {
			var p:ParentAttributePreprocessor = new ParentAttributePreprocessor();
			var xml:XML = <objects>
					<object id="parentObject" abstract="true"/>
					<object id="childObject" parent="parentObject"/>
				</objects>;
			xml = p.preprocess(xml);
			var node:XML = xml.children()[1];

			assertTrue(node.@["abstract"] == undefined);
		}

		[Test]
		public function testPreprocess_shouldInsertClassAttributeInChildObject():void {
			var p:ParentAttributePreprocessor = new ParentAttributePreprocessor();
			var xml:XML = <objects>
					<object id="parentObject" class="Object"/>
					<object id="childObject" parent="parentObject"/>
				</objects>;
			xml = p.preprocess(xml);
			var node:XML = xml.children()[1];

			assertTrue(node.@["class"] == "Object");
		}

		[Test]
		public function testPreprocess_shouldInsertAttributesInChildObject():void {
			var p:ParentAttributePreprocessor = new ParentAttributePreprocessor();
			var xml:XML = <objects>
					<object id="parentObject" class="Object" scope="prototype"/>
					<object id="childObject" parent="parentObject"/>
				</objects>;
			xml = p.preprocess(xml);
			var node:XML = xml.children()[1];

			assertTrue(node.@["class"] == "Object");
			assertTrue(node.@["scope"] == "prototype");
		}

		[Test]
		public function testPreprocess_shouldInsertSubNodeInChildObject():void {
			var p:ParentAttributePreprocessor = new ParentAttributePreprocessor();
			var xml:XML = <objects>
					<object id="parentObject">
						<constructor-arg value="test"/>
					</object>
					<object id="childObject" parent="parentObject"/>
				</objects>;
			xml = p.preprocess(xml);
			var childNode:XML = xml.children()[1];

			assertEquals(1, childNode.children().length());

			var constructorArgNode:XML = childNode.children()[0];
			assertEquals("constructor-arg", constructorArgNode.name());
			assertTrue(constructorArgNode.@value != undefined);
			assertEquals("test", constructorArgNode.@value);
		}

		[Test]
		public function testPreprocess_shouldNotReplaceConstructorElementsInChildObject():void {
			var p:ParentAttributePreprocessor = new ParentAttributePreprocessor();
			var xml:XML = <objects>
					<object id="parentObject">
						<constructor-arg value="test"/>
					</object>
					<object id="childObject" parent="parentObject">
						<constructor-arg value="test2"/>
					</object>
				</objects>;
			xml = p.preprocess(xml);
			var childNode:XML = xml.children()[1];

			assertEquals(1, childNode.children().length());

			var constructorArgNode:XML = childNode.children()[0];
			assertEquals("constructor-arg", constructorArgNode.name());
			assertTrue(constructorArgNode.@value != undefined);
			assertEquals("test2", constructorArgNode.@value);
		}

		[Test]
		public function testPreprocess_shouldNotReplaceConstructorElementsInChildObject2():void {
			var p:ParentAttributePreprocessor = new ParentAttributePreprocessor();
			var xml:XML = <objects>
					<object id="parentObject">
						<constructor-arg value="test"/>
						<property name="a" value="b"/>
					</object>
					<object id="childObject" parent="parentObject">
						<constructor-arg value="test2"/>
					</object>
				</objects>;
			xml = p.preprocess(xml);
			var childNode:XML = xml.children()[1];

			assertEquals(2, childNode.children().length());

			var constructorArgNode:XML = childNode.children()[0];
			assertEquals("constructor-arg", constructorArgNode.name());
			assertTrue(constructorArgNode.@value != undefined);
			assertEquals("test2", constructorArgNode.@value);
		}

		[Test]
		public function testPreprocess_shouldAddPropertyElementsInChildObject():void {
			var p:ParentAttributePreprocessor = new ParentAttributePreprocessor();
			var xml:XML = <objects>
					<object id="parentObject">
						<property name="a" value="b"/>
					</object>
					<object id="childObject" parent="parentObject">
						<property name="c" value="d"/>
					</object>
				</objects>;
			xml = p.preprocess(xml);
			var childNode:XML = xml.children()[1];

			assertEquals(2, childNode.children().length());
		}

		[Test]
		public function testPreprocess_shouldOverrideParentPropertyInChild():void {
			var p:ParentAttributePreprocessor = new ParentAttributePreprocessor();
			var xml:XML = <objects>
					<object id="parentObject">
						<property name="a" value="b"/>
					</object>
					<object id="childObject" parent="parentObject">
						<property name="a" value="c"/>
					</object>
				</objects>;
			xml = p.preprocess(xml);
			var childNode:XML = xml.children()[1];

			assertEquals(1, childNode.children().length());
			assertEquals("c", childNode.property[0].@value);
		}
	}
}
