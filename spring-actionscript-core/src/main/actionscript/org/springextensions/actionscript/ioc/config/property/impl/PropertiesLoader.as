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
package org.springextensions.actionscript.ioc.config.property.impl {

	import org.as3commons.async.operation.OperationQueue;
	import org.as3commons.async.operation.impl.LoadURLOperation;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesLoader;
	import org.springextensions.actionscript.ioc.config.property.PropertyURI;

	public class PropertiesLoader extends OperationQueue implements IPropertiesLoader {

		private static const QUESTION_MARK:String = '?';
		private static const AMPERSAND:String = "&";

		private var _results:Vector.<String>;

		public function PropertiesLoader(name:String="") {
			super(name);
		}

		public function addURIs(URIs:Vector.<PropertyURI>):void {
			for each (var propertyURI:PropertyURI in URIs) {
				addURI(propertyURI.propertyURI, propertyURI.preventCache);
			}
		}

		public function addURI(URI:String, preventCache:Boolean=true):void {
			var loader:LoadURLOperation = new LoadURLOperation(formatURL(URI, preventCache));
			loader.addCompleteListener(propertiesLoaderComplete, false, 0, true);
			addOperation(loader);
		}

		protected function propertiesLoaderComplete(source:String):void {
			_results ||= new Vector.<String>();
			_results[_results.length] = source;
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

		override public function dispatchCompleteEvent(result:*=null):Boolean {
			return super.dispatchCompleteEvent(_results);
		}

	}
}
