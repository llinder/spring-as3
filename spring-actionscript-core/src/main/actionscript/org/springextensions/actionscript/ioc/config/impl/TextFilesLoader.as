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
package org.springextensions.actionscript.ioc.config.impl {

	import flash.utils.Dictionary;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.async.operation.event.OperationEvent;
	import org.as3commons.async.operation.impl.LoadURLOperation;
	import org.as3commons.async.operation.impl.OperationQueue;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getClassLogger;
	import org.springextensions.actionscript.ioc.config.ITextFilesLoader;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class TextFilesLoader extends OperationQueue implements ITextFilesLoader {

		private static const LOGGER:ILogger = getClassLogger(TextFilesLoader);
		private static const QUESTION_MARK:String = '?';
		private static const AMPERSAND:String = "&";

		private var _requiredFiles:Dictionary;
		private var _results:Vector.<String>;

		/**
		 * Creates a new <code>TextFilesLoader</code> instance.
		 * @param name An optional name for the current <code>TextFilesLoader</code>.
		 */
		public function TextFilesLoader(name:String="") {
			super(name);
			_requiredFiles = new Dictionary(true);
		}

		/**
		 * @inheritDoc
		 */
		public function addURIs(URIs:Vector.<TextFileURI>):void {
			for each (var propertyURI:TextFileURI in URIs) {
				addURI(propertyURI.textFileURI, propertyURI.preventCache, propertyURI.isRequired);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function addURI(URI:String, preventCache:Boolean=true, isRequired:Boolean=true):void {
			var loader:LoadURLOperation = new LoadURLOperation(formatURL(URI, preventCache));
			if (isRequired) {
				_requiredFiles[loader] = true;
			}
			loader.addCompleteListener(textFileLoaderComplete);
			loader.addErrorListener(textFileLoaderError);
			addOperation(loader);
		}

		/**
		 *
		 * @param event
		 */
		protected function textFileLoaderError(event:OperationEvent):void {
			cleanUpLoadURLOperation(event.operation);
			if (_requiredFiles[event.operation] == true) {
				throw new Error(event.error);
			} else {
				LOGGER.debug("Failed to load {0}", [Object(event.operation).toString()]);
			}
		}

		/**
		 *
		 * @param operation
		 */
		protected function cleanUpLoadURLOperation(operation:IOperation):void {
			if (_requiredFiles[operation] != null) {
				delete _requiredFiles[operation];
			}
			operation.removeCompleteListener(textFileLoaderComplete);
			operation.removeErrorListener(textFileLoaderError);
		}

		/**
		 *
		 * @param event
		 */
		protected function textFileLoaderComplete(event:OperationEvent):void {
			cleanUpLoadURLOperation(event.operation);
			_results ||= new Vector.<String>();
			_results[_results.length] = String(event.result);
			LOGGER.debug("Completed operation {0}", [event.operation]);
		}

		/**
		 * Adds a random number to the url, checks if a '?' character is already part of the string
		 * than suffixes a '&amp;' character
		 * @param url The url that will be processed
		 * @param preventCache
		 * @return The formatted URL
		 */
		public function formatURL(url:String, preventCache:Boolean):String {
			if (preventCache) {
				var parameterAppendChar:String = (url.indexOf(QUESTION_MARK) < 0) ? QUESTION_MARK : AMPERSAND;
				url += (parameterAppendChar + Math.round(Math.random() * 1000000));
			}
			return url;
		}

		/**
		 * @inheritDoc
		 */
		override public function dispatchCompleteEvent(result:*=null):Boolean {
			return super.dispatchCompleteEvent(_results);
			LOGGER.debug("Completed loading of {0} text file(s)", [_results.length]);
		}

	}
}
