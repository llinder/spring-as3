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
package org.springextensions.actionscript.ioc.config.impl.xml {
	import flash.utils.ByteArray;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.async.operation.OperationQueue;
	import org.as3commons.async.operation.impl.LoadURLOperation;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.XMLUtils;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.impl.AsyncObjectDefinitionProviderResultOperation;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class XMLObjectDefinitionsProvider implements IObjectDefinitionsProvider, IDisposable {

		private static const XML_OBJECT_DEFINITIONS_PROVIDER_QUEUE_NAME:String = "xmlObjectDefinitionsProviderQueue";

		/**
		 * Creates a new <code>XMLObjectDefinitionProvider</code> instance.
		 * @param locations
		 */
		public function XMLObjectDefinitionsProvider(locations:Array) {
			super()
			initXMLObjectDefinitionProvider(locations);
		}

		private var _asyncOperation:AsyncObjectDefinitionProviderResultOperation;
		private var _isDisposed:Boolean;
		private var _loaders:Vector.<LoadURLOperation>;
		private var _locations:Array;
		private var _objectDefinitions:Object;
		private var _operationQueue:OperationQueue;
		private var _propertyURIs:Vector.<TextFileURI>;
		private var _xmlConfiguration:XML;

		/**
		 * @inheritDoc
		 */
		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		/**
		 * @inheritDoc
		 */
		public function get objectDefinitions():Object {
			return _objectDefinitions;
		}

		/**
		 * @inheritDoc
		 */
		public function get propertyURIs():Vector.<TextFileURI> {
			return _propertyURIs;
		}

		/**
		 *
		 * @param location
		 */
		public function addLocation(location:*):void {
			_locations ||= [];
			_locations[_locations.length] = location;
		}

		/**
		 *
		 * @param locations
		 */
		public function addLocations(locations:Array):void {
			_locations ||= [];
			_locations = _locations.concat(locations);
		}

		/**
		 * @inheritDoc
		 */
		public function createDefinitions():IOperation {
			if ((_locations == null) || (_locations.length == 0)) {
				return null;
			}
			_operationQueue = new OperationQueue(XML_OBJECT_DEFINITIONS_PROVIDER_QUEUE_NAME);
			loadLocations(_locations, _operationQueue);
			_asyncOperation = addQueueListeners(_operationQueue);
			return _asyncOperation;
		}

		public function dispose():void {
			if (!_isDisposed) {
				_isDisposed = true;
			}
		}

		protected function addQueueListeners(queue:OperationQueue):AsyncObjectDefinitionProviderResultOperation {
			if (queue.total > 0) {
				queue.addCompleteListener(handleXMLLoadQueueComplete, false, 0, true);
				queue.addErrorListener(handleXMLLoadQueueError, false, 0, true);
				return new AsyncObjectDefinitionProviderResultOperation();
			} else {
				return null;
			}
		}

		protected function handleXMLLoadQueueComplete(result:String):void {
			_xmlConfiguration = XMLUtils.mergeXML(_xmlConfiguration, new XML(result));
		}

		protected function handleXMLLoadQueueError(error:*):void {

		}

		/**
		 * initializes the current <code>XMLObjectDefinitionProvider</code>
		 */
		protected function initXMLObjectDefinitionProvider(locations:Array):void {
			_locations = locations;
		}

		/**
		 *
		 * @param config
		 */
		protected function loadEmbeddedXML(config:Class):void {
			var configInstance:ByteArray = new config();
			var configXML:XML = new XML(configInstance.readUTFBytes(configInstance.length));
			_xmlConfiguration = XMLUtils.mergeXML(_xmlConfiguration, configXML);
		}

		/**
		 *
		 * @param xml
		 */
		protected function loadExplicitXML(xml:XML):void {
			_xmlConfiguration = XMLUtils.mergeXML(_xmlConfiguration, xml);
		}

		protected function loadLocations(xmlLocations:Array, queue:OperationQueue):void {
			for each (var item:* in xmlLocations) {
				if (item is String) {
					loadRemoteXML(String(item), queue)
				} else if (item is Class) {
					loadEmbeddedXML(Class(item));
				} else if (item is XML) {
					loadExplicitXML(XML(item));
				}
			}
		}

		/**
		 *
		 * @param URI
		 */
		protected function loadRemoteXML(URI:String, queue:OperationQueue):void {

		}
	}
}
