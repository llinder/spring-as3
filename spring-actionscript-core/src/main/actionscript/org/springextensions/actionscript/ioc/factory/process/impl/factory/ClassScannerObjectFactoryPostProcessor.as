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
package org.springextensions.actionscript.ioc.factory.process.impl.factory {
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.system.ApplicationDomain;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.bytecode.reflect.ByteCodeType;
	import org.as3commons.bytecode.reflect.ByteCodeTypeCache;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.IOrdered;
	import org.as3commons.lang.util.OrderedUtils;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.ioc.config.impl.metadata.ILoaderInfoAware;
	import org.springextensions.actionscript.ioc.config.impl.metadata.WaitingOperation;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.metadata.classscanner.IClassScanner;
	import org.springextensions.actionscript.util.ContextUtils;
	import org.springextensions.actionscript.util.Environment;

	/**
	 * Factory post processor that creates a lookup of metadata names and class names. It also acts as
	 * a registry for <code>IClassScanner</code> implementations that will be invoked for the metadata
	 * names that were extracted from the loaderInfo.
	 * @author Christophe Herreman
	 * @author Roland Zwaga
	 */
	public class ClassScannerObjectFactoryPostProcessor implements IObjectFactoryPostProcessor, IApplicationDomainAware, IOrdered, IDisposable {

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>ClassScannerObjectFactoryPostProcessor</code>.
		 */
		public function ClassScannerObjectFactoryPostProcessor() {
			super();
		}

		// --------------------------------------------------------------------
		//
		// Private Variables
		//
		// --------------------------------------------------------------------

		private var _applicationDomain:ApplicationDomain;
		private var _isDisposed:Boolean;
		private var _order:int = 0;
		private var _scanners:Vector.<IClassScanner>;
		private var _timeOutToken:uint = 0;
		private var _waitingOperation:WaitingOperation;
		private var _objectFactory:IObjectFactory;

		// --------------------------------------------------------------------
		//
		// Public Properties
		//
		// --------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}

		/**
		 *
		 */
		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		/**
		 *
		 */
		public function get order():int {
			return _order;
		}

		/**
		 * @private
		 */
		public function set order(value:int):void {
			_order = value;
		}

		/**
		 *
		 */
		public function get scanners():Vector.<IClassScanner> {
			return _scanners;
		}

		/**
		 * @private
		 */
		public function set scanners(value:Vector.<IClassScanner>):void {
			_scanners = value;
		}

		// --------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------

		/**
		 *
		 * @param scanner
		 */
		public function addScanner(scanner:IClassScanner):void {
			_scanners ||= new Vector.<IClassScanner>();
			if (_scanners.indexOf(scanner) < 0) {
				_scanners[_scanners.length] = scanner;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			if (!_isDisposed) {
				_applicationDomain = null;
				for each (var scanner:IClassScanner in _scanners) {
					ContextUtils.disposeInstance(scanner);
				}
				if (_timeOutToken > 0) {
					clearTimeout(_timeOutToken);
				}
				ContextUtils.disposeInstance(_waitingOperation);
				_waitingOperation = null;
				_objectFactory = null;
				_isDisposed = true;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation {
			_objectFactory = objectFactory;
			registerClassScanners(objectFactory);
			var operation:IOperation;
			if ((_scanners != null) && (_scanners.length > 0)) {
				var loaderInfo:LoaderInfo = (objectFactory as ILoaderInfoAware) ? ILoaderInfoAware(objectFactory).loaderInfo : null;
				operation = doMetaDataScan(loaderInfo);
			}
			return operation;
		}

		// --------------------------------------------------------------------
		//
		// Protected Methods
		//
		// --------------------------------------------------------------------

		/**
		 *
		 * @param loaderInfo
		 * @return
		 */
		protected function doMetaDataScan(loaderInfo:LoaderInfo):IOperation {
			if (loaderInfo != null) {
				ByteCodeType.metaDataLookupFromLoader(loaderInfo);
				doScans();
				if (_waitingOperation != null) {
					_waitingOperation.dispatchCompleteEvent();
				}
				return null;
			} else if (!Environment.isFlash) {
				return waitForStage();
			} else {
				throw new IllegalOperationError("loaderInfo instance must not be null");
			}
		}

		/**
		 *
		 */
		protected function doScans():void {
			var typeCache:ByteCodeTypeCache = (ByteCodeType.getTypeProvider().getTypeCache() as ByteCodeTypeCache);
			_scanners = _scanners.sort(OrderedUtils.orderedCompareFunction);
			for each (var scanner:IClassScanner in _scanners) {
				if (scanner is IApplicationDomainAware) {
					var aa:IApplicationDomainAware = IApplicationDomainAware(scanner);
					aa.applicationDomain = _applicationDomain;
				}
				if (scanner is IApplicationContextAware) {
					var aca:IApplicationContextAware = IApplicationContextAware(scanner);
					if (aca.applicationContext == null) {
						aca.applicationContext = _objectFactory as IApplicationContext;
					}
				}
				for each (var name:String in scanner.metaDataNames) {
					var classNames:Array = typeCache.getClassesWithMetadata(name);
					for each (var className:String in classNames) {
						scanner.scan(className);
					}
				}
			}
		}

		/**
		 *
		 * @param objectFactory
		 */
		protected function registerClassScanners(objectFactory:IObjectFactory):void {
			var scanners:Vector.<String> = objectFactory.objectDefinitionRegistry.getObjectNamesForType(IClassScanner);
			for each (var scannerName:String in scanners) {
				addScanner(objectFactory.getObject(scannerName));
			}
		}

		/**
		 *
		 */
		protected function setStageTimer():void {
			if (_timeOutToken < 1) {
				_timeOutToken = setTimeout(function():void {
					clearTimeout(_timeOutToken);
					_timeOutToken = 0;
					var stage:Stage = Environment.getCurrentStage();
					if (stage == null) {
						setStageTimer();
					} else {
						doMetaDataScan(stage.loaderInfo);
					}
				}, 500);
			}
		}

		/**
		 *
		 * @return
		 */
		protected function waitForStage():IOperation {
			_waitingOperation = new WaitingOperation();
			setStageTimer();
			return _waitingOperation;
		}
	}
}
