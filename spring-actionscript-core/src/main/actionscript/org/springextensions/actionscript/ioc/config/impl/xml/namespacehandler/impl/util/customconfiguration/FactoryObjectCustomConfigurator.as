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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.util.customconfiguration {

	import org.springextensions.actionscript.ioc.factory.impl.GenericFactoryObject;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class FactoryObjectCustomConfigurator implements ICustomConfigurator {
		private var _factoryMethod:String;

		/**
		 * Creates a new <code>FactoryObjectCustomConfigurator</code> instance.
		 */
		public function FactoryObjectCustomConfigurator(factoryMethodName:String) {
			super();
			_factoryMethod = factoryMethodName;
		}

		public function execute(instance:*, objectDefinition:IObjectDefinition):* {
			return new GenericFactoryObject(instance, _factoryMethod, objectDefinition.isSingleton);
		}
	}
}
