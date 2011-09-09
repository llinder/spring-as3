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
package org.springextensions.actionscript.ioc.config.impl.mxml.custom {
	import flash.events.Event;

	import mx.utils.UIDUtil;

	import org.as3commons.lang.StringUtils;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.config.impl.mxml.component.MXMLObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinitionBuilder;
	import org.springextensions.actionscript.stage.DefaultAutowiringStageProcessor;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class StageAutowireProcessor extends AbstractCustomObjectDefinitionComponent {
		public static const OBJECTSELECTOR_CHANGED_EVENT:String = "objectSelectorChanged";

		/**
		 * Creates a new <code>StageAutowireProcessor</code> instance.
		 */
		public function StageAutowireProcessor() {
			super();
		}

		private var _objectSelector:Object;

		[Bindable(event="objectSelectorChanged")]
		public function get objectSelector():Object {
			return _objectSelector;
		}

		public function set objectSelector(value:Object):void {
			if (_objectSelector != value) {
				_objectSelector = value;
				dispatchEvent(new Event(OBJECTSELECTOR_CHANGED_EVENT));
			}
		}

		override public function execute(applicationContext:IApplicationContext, objectDefinitions:Object):void {
			var result:ObjectDefinitionBuilder = ObjectDefinitionBuilder.objectDefinitionForClass(DefaultAutowiringStageProcessor);
			result.objectDefinition.customConfiguration = resolveObjectSelectorName();
			if (!StringUtils.hasText(this.id)) {
				this.id = UIDUtil.createUID();
			}
			objectDefinitions[this.id] = result.objectDefinition;
		}

		protected function resolveObjectSelectorName():* {
			return (_objectSelector is MXMLObjectDefinition) ? MXMLObjectDefinition(_objectSelector).id : _objectSelector;
		}

	}
}
