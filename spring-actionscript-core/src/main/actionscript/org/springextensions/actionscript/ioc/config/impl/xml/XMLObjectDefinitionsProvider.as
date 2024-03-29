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
	import flash.errors.IllegalOperationError;
	import flash.system.System;
	import flash.utils.ByteArray;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.async.operation.IOperationQueue;
	import org.as3commons.async.operation.event.OperationEvent;
	import org.as3commons.lang.Assert;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.lang.XMLUtils;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.ITextFilesLoader;
	import org.springextensions.actionscript.ioc.config.impl.AsyncObjectDefinitionProviderResultOperation;
	import org.springextensions.actionscript.ioc.config.impl.TextFilesLoader;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.INamespaceHandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.impl.XMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.IXMLObjectDefinitionsPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.AttributeToElementPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.IdAttributePreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.InnerObjectsPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.MethodInvocationPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.PropertyElementsPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.PropertyImportPreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.ScopeAttributePreprocessor;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.impl.SpringNamesPreprocessor;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;
	import org.springextensions.actionscript.ioc.config.property.impl.Properties;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistryAware;
	import org.springextensions.actionscript.util.ContextUtils;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class XMLObjectDefinitionsProvider implements IObjectDefinitionsProvider, IDisposable, IApplicationContextAware {

		private static const DISPOSE_XML_METHOD_NAME:String = "disposeXML";
		private static const XML_OBJECT_DEFINITIONS_PROVIDER_QUEUE_NAME:String = "xmlObjectDefinitionsProviderQueue";
		private static const XML_OBJECT_DEFINITON_XMLLOADER_Name:String = "xmlObjectDefinitonXMLLoader";

		/**
		 * Creates a new <code>XMLObjectDefinitionProvider</code> instance.
		 * @param locations
		 */
		public function XMLObjectDefinitionsProvider(locations:Array=null) {
			super()
			initXMLObjectDefinitionProvider(locations);
		}

		private var _applicationContext:IApplicationContext;
		private var _asyncOperation:AsyncObjectDefinitionProviderResultOperation;
		private var _isDisposed:Boolean;
		private var _locations:Array;
		private var _namespaceHandlers:Vector.<INamespaceHandler>;
		private var _objectDefinitions:Object;
		private var _parser:IXMLObjectDefinitionsParser;
		private var _preprocessors:Vector.<IXMLObjectDefinitionsPreprocessor>;
		private var _preprocessorsInitialized:Boolean;
		private var _propertiesProvider:IPropertiesProvider;
		private var _propertyURIs:Vector.<TextFileURI>;
		private var _textFilesLoader:ITextFilesLoader;
		private var _xmlConfiguration:XML;

		public function get applicationContext():IApplicationContext {
			return _applicationContext;
		}

		public function set applicationContext(value:IApplicationContext):void {
			_applicationContext = value;
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
		public function get parser():IXMLObjectDefinitionsParser {
			return _parser;
		}

		/**
		 * @inheritDoc
		 */
		public function set parser(value:IXMLObjectDefinitionsParser):void {
			_parser = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get propertiesProvider():IPropertiesProvider {
			return _propertiesProvider;
		}

		/**
		 * @inheritDoc
		 */
		public function get propertyURIs():Vector.<TextFileURI> {
			return _propertyURIs;
		}

		/**
		 * @inheritDoc
		 */
		public function get textFilesLoader():ITextFilesLoader {
			return _textFilesLoader;
		}

		/**
		 * @inheritDoc
		 */
		public function set textFilesLoader(value:ITextFilesLoader):void {
			_textFilesLoader = value;
		}

		/**
		 *
		 * @param location
		 */
		public function addLocation(location:*):XMLObjectDefinitionsProvider {
			_locations ||= [];
			if (_locations.indexOf(location) < 0) {
				_locations[_locations.length] = location;
			}
			return this;
		}

		/**
		 *
		 * @param locations
		 */
		public function addLocations(locations:Array):XMLObjectDefinitionsProvider {
			_locations = (_locations == null) ? locations : _locations.concat(locations);
			return this;
		}

		/**
		 * Adds a <code>INamespaceHandler</code> to the current <code>XMLObjectDefinitionsProvider</code>.
		 * @param namespaceHandler
		 */
		public function addNamespaceHandler(namespaceHandler:INamespaceHandler):XMLObjectDefinitionsProvider {
			Assert.notNull(namespaceHandler, "The namespaceHandler argument must not be null");
			if (_applicationContext.dependencyInjector != null) {
				_applicationContext.dependencyInjector.wire(namespaceHandler, _applicationContext);
			}
			_namespaceHandlers ||= new Vector.<INamespaceHandler>();
			if (_namespaceHandlers.indexOf(namespaceHandler) < 0) {
				_namespaceHandlers[_namespaceHandlers.length] = namespaceHandler;
			}
			if (namespaceHandler is IXMLObjectDefinitionsPreprocessor) {
				addPreprocessor(IXMLObjectDefinitionsPreprocessor(namespaceHandler));
			}
			return this;
		}

		/**
		 * Adds a list <code>INamespaceHandlers</code> to the current <code>XMLObjectDefinitionsProvider</code>.
		 * @param namespaceHandler
		 */
		public function addNamespaceHandlers(namespaceHandlers:Vector.<INamespaceHandler>):XMLObjectDefinitionsProvider {
			Assert.notNull(namespaceHandlers, "The namespaceHandlers argument must not be null");
			for each (var handler:INamespaceHandler in namespaceHandlers) {
				addNamespaceHandler(handler);
			}
			return this;
		}

		/**
		 * Adds a <code>IXMLObjectDefinitionsPreprocessor</code> to the current <code>XMLObjectDefinitionsProvider</code>.
		 * @param preprocessor    The implementation of IXMLObjectDefinitionsPreprocessor that will be added
		 */
		public function addPreprocessor(preprocessor:IXMLObjectDefinitionsPreprocessor):XMLObjectDefinitionsProvider {
			Assert.notNull(preprocessor, "The preprocessor argument must not be null");
			_preprocessors ||= new Vector.<IXMLObjectDefinitionsPreprocessor>();
			if (_preprocessors.indexOf(preprocessor) < 0) {
				_preprocessors[_preprocessors.length] = preprocessor;
			}
			return this;
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

		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			if (!_isDisposed) {
				disposeXML(_xmlConfiguration);
				if (_locations != null) {
					for each (var item:* in _locations) {
						if (item is XML) {
							disposeXML(item);
						}
					}
					_locations.length = 0;
				}
				_locations = null;
				_applicationContext = null;
				_asyncOperation = null;
				if (_preprocessors != null) {
					for each (var processor:IXMLObjectDefinitionsPreprocessor in _preprocessors) {
						ContextUtils.disposeInstance(processor);
					}
					_preprocessors.length = 0;
				}
				_preprocessors = null;
				if (_namespaceHandlers != null) {
					for each (var handler:INamespaceHandler in _namespaceHandlers) {
						ContextUtils.disposeInstance(handler);
					}
					_namespaceHandlers.length = 0;
				}
				_namespaceHandlers = null;
				_propertyURIs = null;
				ContextUtils.disposeInstance(_parser);
				_parser = null;
				ContextUtils.disposeInstance(_textFilesLoader);
				_textFilesLoader = null;
				_isDisposed = true;
			}
		}

		/**
		 *
		 * @param queue
		 * @return
		 */
		protected function addQueueListeners(queue:IOperationQueue):AsyncObjectDefinitionProviderResultOperation {
			if ((queue != null) && (queue.total > 0)) {
				queue.addCompleteListener(handleXMLLoadQueueComplete, false, 0, true);
				queue.addErrorListener(handleXMLLoadQueueError, false, 0, true);
				return new AsyncObjectDefinitionProviderResultOperation();
			} else {
				return null;
			}
		}

		/**
		 *
		 * @param xml
		 */
		protected function addXMLConfig(xml:XML):void {
			_xmlConfiguration = XMLUtils.mergeXML(_xmlConfiguration, xml);
		}

		/**
		 *
		 * @return
		 */
		protected function createParser():IXMLObjectDefinitionsParser {
			var result:XMLObjectDefinitionsParser = new XMLObjectDefinitionsParser(_applicationContext);
			result.addNamespaceHandlers(_namespaceHandlers);
			return result;
		}

		/**
		 *
		 * @param merge
		 */
		protected function disposeXML(xml:XML):void {
			if (xml == null) {
				return;
			}
			try {
				System[DISPOSE_XML_METHOD_NAME](xml);
			} catch (e:Error) {
			}
		}

		/**
		 *
		 * @param result
		 */
		protected function handleXMLLoadQueueComplete(event:OperationEvent):void {
			var result:Vector.<String> = event.result as Vector.<String>;
			for each (var xmlFile:String in result) {
				addXMLConfig(new XML(xmlFile));
			}
			parseXML(_xmlConfiguration);
			_asyncOperation.dispatchCompleteEvent(this);
		}

		/**
		 *
		 * @param error
		 */
		protected function handleXMLLoadQueueError(event:OperationEvent):void {
			_asyncOperation.dispatchErrorEvent(event.error);
		}

		/**
		 * initializes the current <code>XMLObjectDefinitionProvider</code>
		 */
		protected function initXMLObjectDefinitionProvider(locations:Array):void {
			_locations = locations;
			_propertyURIs = new Vector.<TextFileURI>();
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

		/**
		 *
		 * @param xmlLocations
		 */
		protected function loadLocations(xmlLocations:Array):void {
			for each (var item:* in xmlLocations) {
				if (item is String) {
					loadRemoteXML(String(item))
				} else if (item is Class) {
					loadEmbeddedXML(Class(item));
				} else if (item is XML) {
					loadExplicitXML(XML(item));
				} else {
					throw new IllegalOperationError(StringUtils.substitute("XML location was of an unknown type: {0}, only String, Class or XML types are allowed", ClassUtils.forInstance(item, applicationContext.applicationDomain)));
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

		/**
		 *
		 * @param xmlConfig
		 */
		protected function parseXML(xmlConfig:XML):void {
			preProcessXML(xmlConfig);
			_parser ||= createParser();
			_objectDefinitions = _parser.parse(xmlConfig);
		}

		/**
		 *
		 * @param xmlConfig
		 */
		protected function preProcessXML(xmlConfig:XML):void {
			// initialize the preprocessors
			// do this here because the properties preprocessor needs the properties
			if (!_preprocessorsInitialized) {
				_preprocessorsInitialized = true;
				_propertiesProvider ||= new Properties();
				_propertyURIs ||= new Vector.<TextFileURI>();

				addPreprocessor(new ScopeAttributePreprocessor());
				addPreprocessor(new PropertyImportPreprocessor(_propertyURIs));
				addPreprocessor(new PropertyElementsPreprocessor(_propertiesProvider));
				addPreprocessor(new IdAttributePreprocessor());
				addPreprocessor(new AttributeToElementPreprocessor());
				addPreprocessor(new SpringNamesPreprocessor());
				addPreprocessor(new InnerObjectsPreprocessor());
				addPreprocessor(new MethodInvocationPreprocessor());
				if (_propertiesProvider.length == 0) {
					_propertiesProvider = null;
				}
				if (_propertyURIs.length == 0) {
					_propertyURIs = null;
				}
			}

			for each (var preprocessor:IXMLObjectDefinitionsPreprocessor in _preprocessors) {
				xmlConfig = preprocessor.preprocess(xmlConfig);
			}

		}
	}
}
