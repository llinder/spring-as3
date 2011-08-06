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
package org.springextensions.actionscript.ioc.autowire.impl {
	import asmock.framework.Expect;
	import asmock.framework.SetupResult;
	import asmock.integration.flexunit.IncludeMocksRule;

	import flash.events.Event;
	import flash.system.ApplicationDomain;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.springextensions.actionscript.ioc.AutowireMode;
	import org.springextensions.actionscript.ioc.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;
	import org.springextensions.actionscript.test.AbstractTestWithMockRepository;
	import org.springextensions.actionscript.test.testtypes.AutowiredAnnotatedClass;
	import org.springextensions.actionscript.test.testtypes.AutowiredExternalPropertyAnnotatedClass;


	public class DefaultAutowireProcessorTest extends AbstractTestWithMockRepository {

		{
			DefaultObjectFactory;
		}

		[Rule]
		public var includeMocks:IncludeMocksRule = new IncludeMocksRule([IObjectFactory, IInstanceCache]);

		private var _applicationDomain:ApplicationDomain = ApplicationDomain.currentDomain;
		private var _cache:IInstanceCache;
		private var _factory:IObjectFactory;
		private var _objectDefinitions:Object;

		public function DefaultAutowireProcessorTest() {
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
		public function testFindAutowireCandidateName():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "flash.events.Event";
			_objectDefinitions["testName"] = definition;
			mockRepository.replayAll();

			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			var name:String = processor.findAutowireCandidateName(Event);
			assertEquals("testName", name);
		}

		[Test]
		public function testFindAutowireCandidateNameWithNonExistingCandidate():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "flash.events.Event";
			_objectDefinitions["testName"] = definition;
			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			var name:String = processor.findAutowireCandidateName(String);
			assertNull(name);
		}

		[Test]
		public function testPreprocessObjectDefinitionWithAutoDetectAndClassWithoutConstructorArgs():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "Function";
			definition.autoWireMode = AutowireMode.AUTODETECT;
			_objectDefinitions["testName"] = definition;
			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			processor.preprocessObjectDefinition(definition);
			assertStrictlyEquals(AutowireMode.BYTYPE, definition.autoWireMode);
		}

		[Test]
		public function testPreprocessObjectDefinitionWithAutoDetectAndClassWithConstructorArgs():void {

			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			definition.autoWireMode = AutowireMode.AUTODETECT;
			_objectDefinitions["testName"] = definition;

			var definition2:IObjectDefinition = new ObjectDefinition();
			definition2.className = "org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory";
			definition2.autoWireMode = AutowireMode.NO;
			_objectDefinitions["objectFactory"] = definition2;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			processor.preprocessObjectDefinition(definition);
			assertStrictlyEquals(AutowireMode.CONSTRUCTOR, definition.autoWireMode);
			assertEquals(1, definition.constructorArguments.length);
			assertEquals("objectFactory", definition.constructorArguments[0]);
		}

		[Test(expects = "org.springextensions.actionscript.ioc.UnsatisfiedDependencyError")]
		public function testPreprocessObjectDefinitionWithAutoDetectAndUnsatisfiedDependency():void {

			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			definition.autoWireMode = AutowireMode.AUTODETECT;
			definition.dependencyCheck = DependencyCheckMode.ALL;
			_objectDefinitions["testName"] = definition;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			processor.preprocessObjectDefinition(definition);
		}

		[Test(expects = "org.springextensions.actionscript.ioc.UnsatisfiedDependencyError")]
		public function testPreprocessObjectDefinitionWithAutoDetectAndUnsatisfiedDependencyAndObjectsCheck():void {

			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			definition.autoWireMode = AutowireMode.AUTODETECT;
			definition.dependencyCheck = DependencyCheckMode.OBJECTS;
			_objectDefinitions["testName"] = definition;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			processor.preprocessObjectDefinition(definition);
		}

		[Test]
		public function testPreprocessObjectDefinitionWithAutoDetectAndIgnoredUnsatisfiedDependency():void {

			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			definition.autoWireMode = AutowireMode.AUTODETECT;
			definition.dependencyCheck = DependencyCheckMode.SIMPLE;
			_objectDefinitions["testName"] = definition;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			processor.preprocessObjectDefinition(definition);
			assertStrictlyEquals(AutowireMode.CONSTRUCTOR, definition.autoWireMode);
			assertEquals(1, definition.constructorArguments.length);
			assertNull(definition.constructorArguments[0]);
		}

		[Test]
		public function testPreprocessObjectDefinitionWithAutoDetectAndWithoutDependencyCheck():void {

			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			definition.autoWireMode = AutowireMode.AUTODETECT;
			definition.dependencyCheck = DependencyCheckMode.NONE;
			_objectDefinitions["testName"] = definition;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			processor.preprocessObjectDefinition(definition);
			assertStrictlyEquals(AutowireMode.CONSTRUCTOR, definition.autoWireMode);
			assertEquals(1, definition.constructorArguments.length);
			assertNull(definition.constructorArguments[0]);
		}

		[Test]
		public function testFindAutowireCandidate():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			_objectDefinitions["testName"] = definition;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			var result:String = processor.findAutowireCandidateName(DefaultAutowireProcessor);
			assertEquals("testName", result);
		}

		[Test]
		public function testFindAutowireCandidateWithAutowireCandidateSetToFalse():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			definition.isAutoWireCandidate = false;
			_objectDefinitions["testName"] = definition;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			var result:String = processor.findAutowireCandidateName(DefaultAutowireProcessor);
			assertNull(result);
		}

		[Test]
		public function testFindAutowireCandidateWithTwoCandidates():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			_objectDefinitions["testName"] = definition;

			definition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			_objectDefinitions["testName2"] = definition;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			var result:String = processor.findAutowireCandidateName(DefaultAutowireProcessor);
			assertNull(result);
		}

		[Test]
		public function testFindAutowireCandidateWithTwoCandidatesAndOneIsPrimary():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			_objectDefinitions["testName"] = definition;

			definition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			definition.primary = true;
			_objectDefinitions["testName2"] = definition;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			var result:String = processor.findAutowireCandidateName(DefaultAutowireProcessor);
			assertEquals("testName2", result);
		}

		[Test(expects = "org.springextensions.actionscript.ioc.factory.NoSuchObjectDefinitionError")]
		public function testFindAutowireCandidateWithTwoCandidatesAndBothArePrimary():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			definition.primary = true;
			_objectDefinitions["testName"] = definition;

			definition = new ObjectDefinition();
			definition.className = "org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor";
			definition.primary = true;
			_objectDefinitions["testName2"] = definition;

			mockRepository.replayAll();
			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			var result:String = processor.findAutowireCandidateName(DefaultAutowireProcessor);
		}

		[Test]
		public function testAutowire():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "String";
			_objectDefinitions["testName"] = definition;

			Expect.call(_factory.getObject("testName")).returnValue("testValue");

			mockRepository.replayAll();

			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);

			var instance:AutowiredAnnotatedClass = new AutowiredAnnotatedClass();
			processor.autoWire(instance);
			assertEquals("testValue", instance.autowiredProperty);
		}

		[Test(expects = "org.springextensions.actionscript.ioc.UnsatisfiedDependencyError")]
		public function testAutowireWithCandidateSetToFalse():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "String";
			definition.isAutoWireCandidate = false;
			definition.dependencyCheck = DependencyCheckMode.NONE;
			_objectDefinitions["testName"] = definition;

			Expect.call(_factory.getObject("testName")).returnValue("testValue");

			mockRepository.replayAll();

			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);

			var instance:AutowiredAnnotatedClass = new AutowiredAnnotatedClass();
			processor.autoWire(instance);
		}

		[Test]
		public function testAutowireWithCheckForOnlyInjectMetadata():void {
			var definition:IObjectDefinition = new ObjectDefinition();
			definition.className = "String";
			_objectDefinitions["testName"] = definition;

			Expect.call(_factory.getObject("testName")).returnValue("testValue");

			mockRepository.replayAll();

			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			processor.autowireMetadataNames = new Vector.<String>();
			processor.autowireMetadataNames[processor.autowireMetadataNames.length] = DefaultAutowireProcessor.INJECT_ANNOTATION;

			var instance:AutowiredAnnotatedClass = new AutowiredAnnotatedClass();
			processor.autoWire(instance);
			assertNull(instance.autowiredProperty);
		}

		[Test]
		public function testAutowireWithExternalProperty():void {
			mockRepository.replayAll();

			var processor:DefaultAutowireProcessor = new DefaultAutowireProcessor(_factory);
			processor.autowireMetadataNames = new Vector.<String>();
			processor.autowireMetadataNames[processor.autowireMetadataNames.length] = DefaultAutowireProcessor.AUTOWIRED_ANNOTATION;

			var instance:AutowiredExternalPropertyAnnotatedClass = new AutowiredExternalPropertyAnnotatedClass();
			processor.autoWire(instance);
			assertEquals("testExternalPropertyValue", instance.injectedExternalProperty);
		}

	}
}
