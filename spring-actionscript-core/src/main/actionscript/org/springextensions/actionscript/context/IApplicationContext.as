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
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	public interface IApplicationContext {
		/**
		 *
		 */
		function get factory():IObjectFactory;
		/**
		 * @private
		 */
		function set factory(value:IObjectFactory):void;
		/**
		 *
		 */
		function get definitionProviders():Vector.<IObjectDefinitionsProvider>;
		/**
		 * @private
		 */
		function set definitionProviders(value:Vector.<IObjectDefinitionsProvider>):void;
		/**
		 *
		 */
		function get definitionRegistry():IObjectDefinitionRegistry;
		/**
		 * @private
		 */
		function set definitionRegistry(value:IObjectDefinitionRegistry):void;
	}
}