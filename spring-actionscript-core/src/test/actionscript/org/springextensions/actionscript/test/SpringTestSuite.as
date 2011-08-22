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
	import integration.objectfactory.ObjectFactoryIntegrationTest;

	import org.as3commons.async.task.impl.Task;
	import org.springextensions.actionscript.context.impl.ApplicationContextTest;
	import org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessorTest;
	import org.springextensions.actionscript.ioc.config.impl.TextFilesLoaderTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.XMLObjectDefinitionsProviderTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.nodeparser.EventHandlerNodeParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.nodeparser.EventRouterNodeParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.TaskElementsPreprocessorTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.TaskNamespaceHandlerTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser.BlockNodeParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser.CompositeCommandNodeParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser.CountProviderNodeParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser.IfNodeParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser.LoadURLNodeParsertest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser.LoadURLStreamNodeParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser.PauseCommandNodeParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser.TaskNodeParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.impl.XmlObjectDefinitionsParserTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.AttributeToElementPreprocessorTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.IdAttributePreprocessorTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.InnerObjectsPreprocessorTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.MethodInvocationPreprocessorTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.PropertyElementsPreprocessorTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.PropertyImportPreprocessorTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.ScopeAttributePreprocessorTest;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.SpringNamesPreprocessorTest;
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
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.RegisterObjectFactoryPostProcessorsFactoryPostProcessorTest;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.RegisterObjectPostProcessorsFactoryPostProcessorTest;
	import org.springextensions.actionscript.ioc.impl.DefaultDependencyInjectorTest;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.DefaultObjectDefinitionRegistryTest;
	import org.springextensions.actionscript.metadata.MetadataProcessorObjectFactoryPostProcessorTest;
	import org.springextensions.actionscript.metadata.MetadataProcessorObjectPostProcessorTest;
	import org.springextensions.actionscript.object.SimpleTypeConverterTest;
	import org.springextensions.actionscript.object.propertyeditor.BooleanPropertyEditorTest;
	import org.springextensions.actionscript.object.propertyeditor.ClassPropertyEditorTest;
	import org.springextensions.actionscript.object.propertyeditor.NumberPropertyEditorTest;
	import org.springextensions.actionscript.util.ContextUtilsTest;
	import org.springextensions.actionscript.util.MultilineStringTest;
	import org.springextensions.actionscript.util.TypeUtilsTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public final class SpringTestSuite {
		//Unit tests
		public var t1:DefaultInstanceCacheTest;
		public var t2:TypeUtilsTest;
		public var t3:SimpleTypeConverterTest;
		public var t4:BooleanPropertyEditorTest;
		public var t5:NumberPropertyEditorTest;
		public var t6:ClassPropertyEditorTest;
		public var t7:DefaultAutowireProcessorTest;
		public var t8:ArrayCollectionReferenceResolverTest;
		public var t9:ArrayReferenceResolverTest;
		public var t10:DictionaryReferenceResolverTest;
		public var t11:ThisReferenceResolverTest;
		public var t12:VectorReferenceResolverTest;
		public var t13:ObjectReferenceResolverTest;
		public var t14:DefaultDependencyInjectorTest;
		public var t15:PropertiesTest;
		public var t16:KeyValuePropertiesParserTest;
		public var t17:DefaultObjectFactoryTest;
		public var t18:ApplicationContextTest;
		public var t19:DefaultObjectDefinitionRegistryTest;
		public var t20:ContextUtilsTest;
		public var t21:MultilineStringTest;
		public var t22:RegisterObjectPostProcessorsFactoryPostProcessorTest;
		public var t23:IdAttributePreprocessorTest;
		public var t24:MethodInvocationPreprocessorTest;
		public var t25:PropertyElementsPreprocessorTest;
		public var t26:ScopeAttributePreprocessorTest;
		public var t27:AttributeToElementPreprocessorTest;
		public var t28:InnerObjectsPreprocessorTest;
		public var t29:PropertyImportPreprocessorTest;
		public var t30:SpringNamesPreprocessorTest;
		public var t31:XMLObjectDefinitionsProviderTest;
		public var t32:TextFilesLoaderTest;
		public var t33:RegisterObjectFactoryPostProcessorsFactoryPostProcessorTest;
		public var t34:MetadataProcessorObjectFactoryPostProcessorTest;
		public var t35:MetadataProcessorObjectPostProcessorTest;
		public var t36:EventRouterNodeParserTest;
		public var t37:EventHandlerNodeParserTest;
		public var t38:BlockNodeParserTest;
		public var t39:CompositeCommandNodeParserTest;
		public var t40:CountProviderNodeParserTest;
		public var t41:IfNodeParserTest;
		public var t42:LoadURLNodeParsertest;
		public var t43:LoadURLStreamNodeParserTest;
		public var t44:PauseCommandNodeParserTest;
		public var t45:TaskNodeParserTest;
		public var t46:TaskElementsPreprocessorTest;
		public var t47:TaskNamespaceHandlerTest;
		public var t48:XmlObjectDefinitionsParserTest;
		//Integrations:
		public var i1:ObjectFactoryIntegrationTest;
	}
}
