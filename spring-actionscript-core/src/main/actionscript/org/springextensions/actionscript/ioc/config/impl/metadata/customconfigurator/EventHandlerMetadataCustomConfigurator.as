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
package org.springextensions.actionscript.ioc.config.impl.metadata.customconfigurator {
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventHandlerMetadataCustomConfigurator extends AbstractCustomMetadataConfigurator {
		/**
		 * Creates a new <code>EventHandlerMetadataCustomConfigurator</code> instance.
		 */
		public function EventHandlerMetadataCustomConfigurator() {
			super();
			metadataNames[metadataNames.length] = "EventHandler";
		}

		override public function execute(metadataName:String, objectName:String, objectDefinition:IObjectDefinition, objectDefinitionsRegistry:IObjectDefinitionRegistry, applicationContext:IApplicationContext):void {
			;
		}

	}
}
