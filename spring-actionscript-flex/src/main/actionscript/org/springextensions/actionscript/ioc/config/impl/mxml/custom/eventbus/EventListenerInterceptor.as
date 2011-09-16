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
package org.springextensions.actionscript.ioc.config.impl.mxml.custom.eventbus {

	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.config.impl.mxml.custom.AbstractCustomObjectDefinitionComponent;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class EventListenerInterceptor extends AbstractCustomObjectDefinitionComponent {
		/**
		 * Creates a new <code>EventListenerInterceptor</code> instance.
		 */
		public function EventListenerInterceptor() {
			super();
		}

		override public function execute(applicationContext:IApplicationContext, objectDefinitions:Object):void {
			;
		}

	}
}
