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
package org.springextensions.actionscript.context.config.impl.xml {

	import org.springextensions.actionscript.context.config.IXMLConfigurationPackage;
	import org.springextensions.actionscript.context.impl.ApplicationContext;
	import org.springextensions.actionscript.context.impl.xml.XMLApplicationContext;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.INamespaceHandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.EventBusNamespacehandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.stageprocessing.StageProcessingNamespaceHandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.TaskNamespaceHandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.util.UtilNamespaceHandler;


	/**
	 *
	 * @author Roland Zwaga
	 */
	public class FullXMLConfigurationPackage implements IXMLConfigurationPackage {

		/**
		 *
		 * @param applicationContext
		 */
		public function execute(applicationContext:ApplicationContext):void {
			var xmlContext:XMLApplicationContext = applicationContext as XMLApplicationContext;
			if (xmlContext != null) {
				xmlContext.addNamespaceHandler(new StageProcessingNamespaceHandler());
				xmlContext.addNamespaceHandler(new EventBusNamespacehandler());
				xmlContext.addNamespaceHandler(new TaskNamespaceHandler());
				xmlContext.addNamespaceHandler(new UtilNamespaceHandler());
			}
		}
	}
}
