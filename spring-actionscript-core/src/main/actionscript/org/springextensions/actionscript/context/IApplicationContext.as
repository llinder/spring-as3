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
package org.springextensions.actionscript.context {
	import flash.display.DisplayObject;

	import org.as3commons.stageprocessing.IStageObjectProcessorRegistryAware;
	import org.springextensions.actionscript.context.config.IConfigurationPackage;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.ITextFilesLoader;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesParser;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public interface IApplicationContext extends IObjectFactory, IStageObjectProcessorRegistryAware {
		/**
		 * Returns a <code>Vector</code> of <code>IApplicationContexts</code> that have been registered as a child of the current <code>IApplicationContext</code>.
		 * @docref stuff
		 */
		function get childContexts():Vector.<IApplicationContext>;
		/**
		 *
		 */
		function get definitionProviders():Vector.<IObjectDefinitionsProvider>;

		/**
		 *
		 */
		function get objectFactoryPostProcessors():Vector.<IObjectFactoryPostProcessor>;

		/**
		 *
		 */
		function get propertiesParser():IPropertiesParser;
		/**
		 * @private
		 */
		function set propertiesParser(value:IPropertiesParser):void;

		/**
		 *
		 */
		function get rootView():DisplayObject;

		/**
		 *
		 */
		function get textFilesLoader():ITextFilesLoader;
		/**
		 * @private
		 */
		function set textFilesLoader(value:ITextFilesLoader):void;

		/**
		 *
		 * @param objectFactory
		 */
		function addChildContext(childContext:IApplicationContext, shareDefinitions:Boolean=true, shareSingletons:Boolean=true, shareEventBus:Boolean=true):IApplicationContext;

		/**
		 *
		 * @param provider
		 */
		function addDefinitionProvider(provider:IObjectDefinitionsProvider):IApplicationContext;
		/**
		 *
		 * @param objectFactoryPostProcessor
		 */
		function addObjectFactoryPostProcessor(objectFactoryPostProcessor:IObjectFactoryPostProcessor):IApplicationContext;

		/**
		 *
		 * @param configurationPackage
		 */
		function configure(configurationPackage:IConfigurationPackage):IApplicationContext;

		/**
		 *
		 */
		function load():void;
	}
}