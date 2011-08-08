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
package org.springextensions.actionscript.test {
	import org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessorTest;
	import org.springextensions.actionscript.ioc.config.property.impl.KeyValuePropertiesParserTest;
	import org.springextensions.actionscript.ioc.config.property.impl.PropertiesTest;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultInstanceCacheTest;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactoryTest;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ArrayCollectionReferenceResolverTest;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ArrayReferenceResolverTest;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.DictionaryReferenceResolverTest;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ObjectReferenceResolverTest;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ThisReferenceResolverTest;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.VectorReferenceResolverTest;
	import org.springextensions.actionscript.ioc.impl.DefaultDependencyInjectorTest;
	import org.springextensions.actionscript.object.SimpleTypeConverterTest;
	import org.springextensions.actionscript.object.propertyeditor.BooleanPropertyEditorTest;
	import org.springextensions.actionscript.object.propertyeditor.ClassPropertyEditorTest;
	import org.springextensions.actionscript.object.propertyeditor.NumberPropertyEditorTest;
	import org.springextensions.actionscript.util.TypeUtilsTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public final class SpringTestSuite {
		public var t7:DefaultAutowireProcessorTest;
		public var t14:DefaultDependencyInjectorTest;
		public var t8:ArrayCollectionReferenceResolverTest;
		public var t9:ArrayReferenceResolverTest;
		public var t10:DictionaryReferenceResolverTest;
		public var t11:ThisReferenceResolverTest;
		public var t12:VectorReferenceResolverTest;
		public var t13:ObjectReferenceResolverTest;
		public var t1:DefaultInstanceCacheTest;
		public var t2:TypeUtilsTest;
		public var t3:SimpleTypeConverterTest;
		public var t4:BooleanPropertyEditorTest;
		public var t5:NumberPropertyEditorTest;
		public var t6:ClassPropertyEditorTest;
		public var t15:PropertiesTest;
		public var t16:KeyValuePropertiesParserTest;
		public var t17:DefaultObjectFactoryTest;
	}
}
