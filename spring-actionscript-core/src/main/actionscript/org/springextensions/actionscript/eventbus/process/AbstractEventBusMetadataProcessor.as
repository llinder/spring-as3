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
package org.springextensions.actionscript.eventbus.process {
	import flash.errors.IllegalOperationError;
	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.eventbus.IEventBusAware;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.reflect.Metadata;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IObjectFactoryAware;
	import org.springextensions.actionscript.metadata.AbstractMetadataProcessor;

	public class AbstractEventBusMetadataProcessor extends AbstractMetadataProcessor implements IObjectFactoryAware {
		/** The "clazz" property of the EventHandler metadata */
		protected static const CLASS_KEY:String = "clazz";
		protected static const COMMA:String = ",";

		/** The "name" property of the EventHandler metadata */
		protected static const NAME_KEY:String = "name";
		/** The "topic" property of the EventHandler metadata */
		protected static const TOPICS_KEY:String = "topics";
		/** The "topicProperties" property of the EventHandler metadata */
		protected static const TOPIC_PROPERTIES_KEY:String = "topicProperties";

		// --------------------------------------------------------------------
		//
		// Private Static Variables
		//
		// --------------------------------------------------------------------

		private static var logger:ILogger = getLogger(AbstractEventBusMetadataProcessor);

		public function AbstractEventBusMetadataProcessor(processBefore:Boolean, metadataNames:Vector.<String>=null) {
			super(processBefore, metadataNames);
		}

		protected var objFactory:IObjectFactory;

		/**
		 * @inheritDoc
		 */
		public function get eventBus():IEventBus {
			return IEventBusAware(objFactory).eventBus;
		}

		public function set objectFactory(objectFactory:IObjectFactory):void {
			if (objectFactory is IEventBusAware) {
				objFactory = objectFactory;
			} else {
				throw new IllegalOperationError("IObjectFactory instance must also implement IEventBusAware");
			}
		}

		protected function getTopics(metaData:Metadata, object:Object):Array {
			var result:Array = [];
			var topicsValue:String;
			var name:String;
			if (metaData.hasArgumentWithKey(TOPICS_KEY)) {
				topicsValue = metaData.getArgument(TOPICS_KEY).value;
				var topics:Array = topicsValue.split(' ').join('').split(COMMA);
				for each (name in topics) {
					result[result.length] = name;
				}
			}
			if (metaData.hasArgumentWithKey(TOPIC_PROPERTIES_KEY)) {
				topicsValue = metaData.getArgument(TOPIC_PROPERTIES_KEY).value;
				var props:Array = topicsValue.split(' ').join('').split(COMMA);
				for each (name in props) {
					if (object.hasOwnProperty(name)) {
						result[result.length] = object[name];
					} else {
						logger.debug("Topic property {0} not found on object {1}", [name, object]);
					}
				}
			}
			return result;
		}
	}
}
