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
	public class MetadataProcessorObjectPostProcessor implements IMetaDataProcessorObjectPostProcessor, IInitializingObject, IObjectFactoryAware, IStageObjectDestroyer {

		private static var LOGGER:ILogger = getLogger(MetadataProcessorObjectPostProcessor);

		// --------------------------------------------------------------------
		//
		// Private Variables
		//
		// --------------------------------------------------------------------

		private var _metadataProcessors:Dictionary;
		private var _metadataDestroyers:Dictionary;

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>MetadataProcessorObjectPostProcessor</code> instance.
		 */
		public function MetadataProcessorObjectPostProcessor() {
			super();
			initMetadataProcessorObjectPostProcessor();
		}

		/**
		 * Initializes the current <code>MetadataProcessorObjectPostProcessor</code>.
		 *
		 */
		protected function initMetadataProcessorObjectPostProcessor():void {
			_metadataProcessors = new Dictionary();
			_metadataDestroyers = new Dictionary();
		}

		// --------------------------------------------------------------------
		//
		// Public Properties
		//
		// --------------------------------------------------------------------

		private var _objectFactory:IObjectFactory;

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
			if (!(object is IMetadataProcessor)) {
				return processObject(_metadataProcessors[true], object, objectName);
			}
			return object;
		}

		/**
		 * Invokes processObject() with all registered <code>IMetadataProcessor</code> that have their
		 * <code>processBeforeInitialization</code> property set to <code>false</code>.
		 * <p>If the specified <code>object</code> is an <code>IMetadataProcessor</code> implementation
		 * it will register it with the current <code>MetadataProcessorObjectPostProcessor</code>.</p>
		 */
		public function postProcessAfterInitialization(object:*, objectName:String):* {
			if (object is IMetadataProcessor) {
				var metaDataProcessor:IMetadataProcessor = IMetadataProcessor(object);
				for each (var metaDataName:String in metaDataProcessor.metadataNames) {
					addProcessor(metaDataName, metaDataProcessor);
				}
				return object;
			}

			return processObject(_metadataProcessors[false], object, objectName);
		}

		/**
		 * Checks if the associated <code>IApplicationContext</code> contains any <code>IMetadataProcessor</code> instances
		 * and registers them.
		 */
		public function afterPropertiesSet():void {
			addMetadataProcessorsFromObjectPostProcessors();
			addMetadataProcessorsFromObjectDefinitions();
			addMetadataDestroyersFromObjectDefinitions();
		}

		/**
		 * @inheritDoc
		 */
		public function addProcessor(metaDataName:String, metaDataProcessor:IMetadataProcessor):void {
			var processorLookup:Dictionary = _metadataProcessors[metaDataProcessor.processBeforeInitialization];
			if (processorLookup == null) {
				processorLookup = new Dictionary();
				_metadataProcessors[metaDataProcessor.processBeforeInitialization] = processorLookup;
			}
			var processorVector:Vector.<IMetadataProcessor> = processorLookup[metaDataName];
			if (processorVector == null) {
				processorVector = new Vector.<IMetadataProcessor>();
			}
			if (processorVector.indexOf(metaDataProcessor) < 0) {
				processorVector[processorVector.length] = metaDataProcessor;
				processorLookup[metaDataName] = processorVector.sort(OrderedUtils.orderedCompareFunction);
			}
		}

		protected function addDestroyer(metaDataName:String, metaDataDestroyer:IMetadataDestroyer):void {
			var destroyerVector:Vector.<IMetadataDestroyer> = _metadataDestroyers[metaDataName] ||= new Vector.<IMetadataDestroyer>();
			if (destroyerVector.indexOf(metaDataDestroyer) < 0) {
				destroyerVector[destroyerVector.length] = metaDataDestroyer;
				_metadataDestroyers[metaDataName] = destroyerVector.sort(OrderedUtils.orderedCompareFunction);
			}
		}


		// --------------------------------------------------------------------
		//
		// Protected Methods
		//
		// --------------------------------------------------------------------

		protected function processObject(names:Dictionary, object:*, objectName:String):* {
			if (names == null) {
				return object;
			}
			var type:Type = Type.forInstance(object, _objectFactory.applicationDomain);
			if (TypeUtils.isSimpleProperty(type)) {
				return object;
			}
			for (var name:String in names) {
				//LOGGER.debug("Invoking IMetadataProcessors for {0} metadata", name);
				var processors:Vector.<IMetadataProcessor> = names[name] as Vector.<IMetadataProcessor>;
				var containers:Array = type.getMetadataContainers(name);
				containers ||= [];
				if (type.hasMetadata(name)) {
					containers[containers.length] = type;
				}
				for each (var cont:MetadataContainer in containers) {
					for each (var proc:IMetadataProcessor in processors) {
						proc.process(object, cont, name, objectName);
					}
				}
			}
			return object;
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
					registerMetadataProcessor(metaDataProcessor);
				}
			}
		}

		protected function addMetadataDestroyersFromObjectDefinitions():void {
			var destroyers:Vector.<String> = _objectFactory.objectDefinitionRegistry.getObjectNamesForType(IMetadataDestroyer);

			if (destroyers != null) {
				LOGGER.debug("{0} IMetadataDestroyers found in object definitions, adding them to the current MetadataProcessorObjectPostProcessor.", [destroyers.length]);
				for each (var name:String in destroyers) {
					var metaDataDestroyer:IMetadataDestroyer = IMetadataDestroyer(_objectFactory.getObject(name));
					registerMetadataDestroyer(metaDataDestroyer);
				}
			}

		}

		protected function getMetadataProcessors(objectPostProcessors:Vector.<IObjectPostProcessor>):Vector.<IMetadataProcessor> {
			var result:Vector.<IMetadataProcessor>;

			for each (var objectPostProcessor:IObjectPostProcessor in objectPostProcessors) {
				if (objectPostProcessor is IMetadataProcessor) {
					result ||= Vector.<IMetadataProcessor>();
					result[result.length] = IMetadataProcessor(objectPostProcessor);
				}
			}

			return result;
		}

		protected function registerMetadataProcessor(metadataProcessor:IMetadataProcessor):void {
			for each (var metaDataName:String in metadataProcessor.metadataNames) {
				LOGGER.debug("Registered metadata '[{0}]' with processor '{1}'", [metaDataName, metadataProcessor]);
				addProcessor(metaDataName, metadataProcessor);
			}
		}

		protected function registerMetadataDestroyer(metaDataDestroyer:IMetadataDestroyer):void {
			for each (var metaDataName:String in metaDataDestroyer.metadataNames) {
				LOGGER.debug("Registered metadata '[{0}]' with destroyer '{1}'", [metaDataName, metaDataDestroyer]);
				addDestroyer(metaDataName, metaDataDestroyer);
			}
		}

		public function destroy(displayObject:DisplayObject):DisplayObject {
			var type:Type = Type.forInstance(displayObject, _objectFactory.applicationDomain);
			if (TypeUtils.isSimpleProperty(type)) {
				return displayObject;
			}
			for (var name:String in _metadataDestroyers) {
				var destroyers:Vector.<IMetadataDestroyer> = _metadataDestroyers[name] as Vector.<IMetadataDestroyer>;
				var containers:Array = [];
				if (type.hasMetadata(name)) {
					containers[containers.length] = type;
				}
				var otherContainers:Array = type.getMetadataContainers(name);
				if (otherContainers != null) {
					containers = containers.concat(otherContainers);
				}
				for each (var container:IMetadataContainer in containers) {
					for each (var destroyer:IMetadataDestroyer in destroyers) {
						destroyer.destroy(displayObject, container, name, null);
					}
				}

			}
			return displayObject;
		}

		public function process(displayObject:DisplayObject):DisplayObject {
			return displayObject;
		}

	}
}
