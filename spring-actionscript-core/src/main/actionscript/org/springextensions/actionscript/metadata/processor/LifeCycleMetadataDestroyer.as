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
package org.springextensions.actionscript.metadata.processor {

	import org.as3commons.reflect.IMetadataContainer;
	import org.as3commons.reflect.Method;
	import org.springextensions.actionscript.metadata.IMetadataDestroyer;

	/**
	 *
	 * @author rolandzwaga
	 */
	public class LifeCycleMetadataDestroyer implements IMetadataDestroyer {
		private static const PRE_DESTROY_NAME:String = "PreDestroy";
		private var _metadataNames:Vector.<String>;

		/**
		 * Creates a new <code>LifeCycleMetadataDestroyer</code> instance.
		 */
		public function LifeCycleMetadataDestroyer() {
			super();
			_metadataNames = new Vector.<String>();
			_metadataNames[_metadataNames.length] = PRE_DESTROY_NAME;
		}

		public function get metadataNames():Vector.<String> {
			return _metadataNames;
		}

		public function destroy(instance:Object, container:IMetadataContainer, metadataName:String, objectName:String):void {
			if (container is Method) {
				instance[(container as Method).name]();
			}
		}
	}
}
