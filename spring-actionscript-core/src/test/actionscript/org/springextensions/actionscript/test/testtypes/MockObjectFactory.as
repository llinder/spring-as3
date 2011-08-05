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
package org.springextensions.actionscript.test.testtypes {

	import flash.system.ApplicationDomain;

	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;


	public class MockObjectFactory implements IObjectFactory {

		private var _getObjectResult:Object;

		public function MockObjectFactory(getObjectResult:Object) {
			super();
			_getObjectResult = getObjectResult;
		}

		public function addObjectFactoryPostProcessor(objectFactoryPostProcessor:IObjectFactoryPostProcessor):void {
		}

		public function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):void {
		}

		public function addReferenceResolver(referenceResolver:IReferenceResolver):void {
		}

		public function get applicationDomain():ApplicationDomain {
			return null;
		}

		public function set applicationDomain(value:ApplicationDomain):void {
		}

		public function get cache():IInstanceCache {
			return null;
		}

		public function createInstance(clazz:Class, constructorArguments:Array = null):* {
			return null;
		}

		public function get dependencyInjector():IDependencyInjector {
			return null;
		}

		public function set dependencyInjector(value:IDependencyInjector):void {
		}

		public function getObject(name:String, constructorArguments:Array = null):* {
			return _getObjectResult;
		}

		public function get isReady():Boolean {
			return false;
		}

		public function get objectDefinitions():Object {
			return null;
		}

		public function get objectFactoryPostProcessors():Vector.<IObjectFactoryPostProcessor> {
			return null;
		}

		public function get objectPostProcessors():Vector.<IObjectPostProcessor> {
			return null;
		}

		public function get parent():IObjectFactory {
			return null;
		}

		public function set parent(value:IObjectFactory):void {
		}

		public function get propertyProviders():Vector.<IPropertiesProvider> {
			return null;
		}

		public function get referenceResolvers():Vector.<IReferenceResolver> {
			return null;
		}

		public function resolveReference(property:*):* {
			return _getObjectResult;
		}

		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return null;
		}

		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
		}
	}
}
