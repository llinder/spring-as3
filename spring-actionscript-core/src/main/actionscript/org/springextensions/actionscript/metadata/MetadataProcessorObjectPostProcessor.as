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
package org.springextensions.actionscript.metadata {
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;

	import org.as3commons.lang.util.OrderedUtils;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.metadata.process.IMetadataProcessor;
	import org.as3commons.metadata.registry.IMetadataProcessorRegistry;
	import org.as3commons.metadata.registry.impl.AS3ReflectMetadataProcessorRegistry;
	import org.as3commons.reflect.IMetadataContainer;
	import org.as3commons.reflect.MetadataContainer;
	import org.as3commons.reflect.Type;
	import org.as3commons.stageprocessing.IStageObjectDestroyer;
	import org.springextensions.actionscript.ioc.factory.IInitializingObject;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IObjectFactoryAware;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.util.TypeUtils;

	/**
	 * Default implementation of the <code>IMetaDataProcessorObjectPostProcessor</code> which acts as the main
	 * registry for <code>IMetaDataProcessor</code> definitions that are found in the specified <code>IObjectFactory</code>.
	 * @author Roland Zwaga
	 */
	public class MetadataProcessorObjectPostProcessor implements IMetaDataProcessorObjectPostProcessor, IInitializingObject, IObjectFactoryAware {

		private static var LOGGER:ILogger = getLogger(MetadataProcessorObjectPostProcessor);

		/**
		 * Creates a new <code>MetadataProcessorObjectPostProcessor</code> instance.
		 */
		public function MetadataProcessorObjectPostProcessor() {
			super();
			_afterInitializationRegistry = new AS3ReflectMetadataProcessorRegistry();
			_beforeInitializationRegistry = new AS3ReflectMetadataProcessorRegistry();
		}

		private var _objectFactory:IObjectFactory;
		private var _afterInitializationRegistry:IMetadataProcessorRegistry;
		private var _beforeInitializationRegistry:IMetadataProcessorRegistry;

		/**
		 * @private
		 */
		public function set objectFactory(objectFactory:IObjectFactory):void {
			_objectFactory = objectFactory;
		}

		// --------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------

		/**
		 * Invokes processObject() with all registered <code>IMetadataProcessor</code> that have their
		 * <code>processBeforeInitialization</code> property set to <code>true</code>.
		 */
		public function postProcessBeforeInitialization(object:*, objectName:String):* {
			return _beforeInitializationRegistry.process(object, objectName);
		}

		/**
		 * Invokes processObject() with all registered <code>IMetadataProcessor</code> that have their
		 * <code>processBeforeInitialization</code> property set to <code>false</code>.
		 * <p>If the specified <code>object</code> is an <code>IMetadataProcessor</code> implementation
		 * it will register it with the current <code>MetadataProcessorObjectPostProcessor</code>.</p>
		 */
		public function postProcessAfterInitialization(object:*, objectName:String):* {
			return _afterInitializationRegistry.process(object, objectName);
		}

		/**
		 * Checks if the associated <code>IApplicationContext</code> contains any <code>IMetadataProcessor</code> instances
		 * and registers them.
		 */
		public function afterPropertiesSet():void {
			addMetadataProcessorsFromObjectPostProcessors();
			addMetadataProcessorsFromObjectDefinitions();
		}

		protected function addMetadataProcessorsFromObjectPostProcessors():void {
			var metadataProcessors:Vector.<IMetadataProcessor> = getMetadataProcessors(_objectFactory.objectPostProcessors);
			if (metadataProcessors != null) {
				LOGGER.debug("{0} IMetadataProcessor found in object post processors, adding them to the current MetadataProcessorObjectPostProcessor.", [metadataProcessors.length]);

				for each (var metadataProcessor:IMetadataProcessor in metadataProcessors) {
					registerMetadataProcessor(metadataProcessor);
				}
			}
		}

		protected function addMetadataProcessorsFromObjectDefinitions():void {
			var processors:Vector.<String> = _objectFactory.objectDefinitionRegistry.getObjectNamesForType(IMetadataProcessor);

			if (processors != null) {
				LOGGER.debug("{0} IMetadataProcessors found in object definitions, adding them to the current MetadataProcessorObjectPostProcessor.", [processors.length]);
				for each (var name:String in processors) {
					var metaDataProcessor:IMetadataProcessor = IMetadataProcessor(_objectFactory.getObject(name));
					if (!(metaDataProcessor is IMetadataDestroyer)) {
						registerMetadataProcessor(metaDataProcessor);
					}
				}
			}
		}

		protected function getMetadataProcessors(objectPostProcessors:Vector.<IObjectPostProcessor>):Vector.<IMetadataProcessor> {
			var result:Vector.<IMetadataProcessor>;

			for each (var objectPostProcessor:IObjectPostProcessor in objectPostProcessors) {
				if ((objectPostProcessor is IMetadataProcessor) && (!(objectPostProcessor is IMetadataDestroyer))) {
					result ||= Vector.<IMetadataProcessor>();
					result[result.length] = IMetadataProcessor(objectPostProcessor);
				}
			}

			return result;
		}

		protected function registerMetadataProcessor(metadataProcessor:IMetadataProcessor):void {
			var registry:IMetadataProcessorRegistry = _afterInitializationRegistry;
			if ((metadataProcessor is ISpringMetadaProcessor) && ((metadataProcessor as ISpringMetadaProcessor).processBeforeInitialization)) {
				registry = _beforeInitializationRegistry;
			}
			registry.addProcessor(metadataProcessor);
		}

		public function get beforeInitializationRegistry():IMetadataProcessorRegistry {
			return _beforeInitializationRegistry;
		}

		public function set beforeInitializationRegistry(value:IMetadataProcessorRegistry):void {
			_beforeInitializationRegistry = value;
		}

		public function get afterInitializationRegistry():IMetadataProcessorRegistry {
			return _afterInitializationRegistry;
		}

		public function set afterInitializationRegistry(value:IMetadataProcessorRegistry):void {
			_afterInitializationRegistry = value;
		}

	}
}
