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
	import flash.system.System;
	import flash.utils.ByteArray;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.async.operation.IOperationQueue;
	import org.as3commons.async.operation.impl.LoadURLOperation;
	import org.as3commons.lang.Assert;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.XMLUtils;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.ITextFilesLoader;
	import org.springextensions.actionscript.ioc.config.impl.AsyncObjectDefinitionProviderResultOperation;
	import org.springextensions.actionscript.ioc.config.impl.TextFilesLoader;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.IXMLObjectDefinitionsPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.AttributeToElementPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.IdAttributePreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.InnerObjectsPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.InterfacePreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.ParentAttributePreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.PropertyElementsPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.PropertyImportPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.ScopeAttributePreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.SpringNamesPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.TemplatePreprocessor;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class XMLObjectDefinitionsProvider implements IObjectDefinitionsProvider, IDisposable {

		private static const XML_OBJECT_DEFINITIONS_PROVIDER_QUEUE_NAME:String = "xmlObjectDefinitionsProviderQueue";
		private static const XML_OBJECT_DEFINITON_XMLLOADER_Name:String = "xmlObjectDefinitonXMLLoader";
		private static const DISPOSE_XML_METHOD_NAME:String = "disposeXML";

		/**
		 * Creates a new <code>XMLObjectDefinitionProvider</code> instance.
		 * @param locations
		 */
		public function XMLObjectDefinitionsProvider(locations:Array) {
			super()
			initXMLObjectDefinitionProvider(locations);
		}

		private var _textFilesLoader:ITextFilesLoader;
		private var _asyncOperation:AsyncObjectDefinitionProviderResultOperation;
		private var _isDisposed:Boolean;
		private var _loaders:Vector.<LoadURLOperation>;
		private var _locations:Array;
		private var _objectDefinitions:Object;
		private var _propertyURIs:Vector.<TextFileURI>;
		private var _xmlConfiguration:XML;
		private var _preprocessorsInitialized:Boolean;
		private var _preprocessors:Vector.<IXMLObjectDefinitionsPreprocessor> = new Vector.<IXMLObjectDefinitionsPreprocessor>();

		public function get textFilesLoader():ITextFilesLoader {
			return _textFilesLoader;
		}

		public function set textFilesLoader(value:ITextFilesLoader):void {
			_textFilesLoader = value;
		}

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
		 * Adds a preprocessor to the parser.
		 *
		 * @param preprocessor    The implementation of IXMLObjectDefinitionsPreprocessor that will be added
		 */
		public function addPreprocessor(preprocessor:IXMLObjectDefinitionsPreprocessor):void {
			Assert.notNull(preprocessor, "The preprocessor argument must not be null");
			_preprocessors ||= new Vector.<IXMLObjectDefinitionsPreprocessor>();
			_preprocessors[_preprocessors.length] = preprocessor;
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
			loadLocations(_locations);
			_asyncOperation = addQueueListeners(_textFilesLoader);
			if (_asyncOperation == null) {
				parseXML(_xmlConfiguration);
			}
			return _asyncOperation;
		}

		public function dispose():void {
			if (!_isDisposed) {
				_isDisposed = true;
			}
		}

		protected function addQueueListeners(queue:IOperationQueue):AsyncObjectDefinitionProviderResultOperation {
			if ((queue != null) && (queue.total > 0)) {
				queue.addCompleteListener(handleXMLLoadQueueComplete, false, 0, true);
				queue.addErrorListener(handleXMLLoadQueueError, false, 0, true);
				return new AsyncObjectDefinitionProviderResultOperation();
			} else {
				return null;
			}
		}

		protected function handleXMLLoadQueueComplete(result:Vector.<String>):void {
			for each (var xmlFile:String in result) {
				addXMLConfig(new XML(xmlFile));
			}
			parseXML(_xmlConfiguration);
		}

		protected function addXMLConfig(xml:XML):void {
			_xmlConfiguration = XMLUtils.mergeXML(_xmlConfiguration, xml);
			disposeXML(xml);
		}

		protected function disposeXML(merge:XML):void {
			try {
				System[DISPOSE_XML_METHOD_NAME](merge);
			} catch (e:Error) {

			}
		}



		protected function handleXMLLoadQueueError(error:*):void {
			_asyncOperation.dispatchErrorEvent(error);
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
			addXMLConfig(new XML(configInstance.readUTFBytes(configInstance.length)));
		}

		/**
		 *
		 * @param xml
		 */
		protected function loadExplicitXML(xml:XML):void {
			addXMLConfig(xml);
		}

		protected function loadLocations(xmlLocations:Array):void {
			for each (var item:* in xmlLocations) {
				if (item is String) {
					loadRemoteXML(String(item))
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
		protected function loadRemoteXML(URI:String):void {
			_textFilesLoader ||= new TextFilesLoader(XML_OBJECT_DEFINITON_XMLLOADER_Name);
			_textFilesLoader.addURI(URI);
		}

		protected function parseXML(xmlConfig:XML):void {
			// pre process the xml
			preProcessXML(xmlConfig);

		}

		protected function preProcessXML(xmlConfig:XML):void {
			// initialize the preprocessors
			// do this here because the properties preprocessor needs the properties
			if (!_preprocessorsInitialized) {
				_preprocessorsInitialized = true;

				addPreprocessor(new PropertyImportPreprocessor());
//				addPreprocessor(new PropertyElementsPreprocessor(applicationContext));
				addPreprocessor(new IdAttributePreprocessor());
				addPreprocessor(new AttributeToElementPreprocessor());
				addPreprocessor(new SpringNamesPreprocessor());
				addPreprocessor(new TemplatePreprocessor());
				addPreprocessor(new ScopeAttributePreprocessor());
				addPreprocessor(new ParentAttributePreprocessor());
				addPreprocessor(new InnerObjectsPreprocessor());
//				addPreprocessor(new InterfacePreprocessor(applicationContext.applicationDomain));
			}

			for each (var preprocessor:IXMLObjectDefinitionsPreprocessor in _preprocessors) {
				xmlConfig = preprocessor.preprocess(xmlConfig);
			}

		}

	}
}
