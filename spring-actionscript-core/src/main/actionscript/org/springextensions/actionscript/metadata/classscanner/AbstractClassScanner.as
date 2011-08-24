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
package org.springextensions.actionscript.metadata.classscanner {
	import flash.errors.IllegalOperationError;

	/**
	 * Abstract base class for <code>IClassScanner</code> implementations.
	 * @author Roland Zwaga
	 * @author Christophe Herreman
	 */
	public class AbstractClassScanner implements IClassScanner {

		private static const NOT_IMPLEMENTED_ERROR:String = "scan method not implemented in abstract base class.";

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>AbstractClassScanner</code> instance.
		 * @param names An optional array of metadata names that will be accessible through the <code>metaDataNames</code> property.
		 */
		public function AbstractClassScanner(names:Vector.<String>=null) {
			super();
			_metaDataNames ||= new Vector.<String>();
		}

		// --------------------------------------------------------------------
		//
		// Public Properties
		//
		// --------------------------------------------------------------------

		// ----------------------------
		// metadataNames
		// ----------------------------

		private var _metaDataNames:Vector.<String>;

		/**
		 * @inheritDoc
		 */
		public function get metaDataNames():Vector.<String> {
			return _metaDataNames;
		}

		// --------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function scan(className:String):void {
			throw new IllegalOperationError(NOT_IMPLEMENTED_ERROR);
		}

		/**
		 * @inheritDoc
		 */
		public function scanClassNames(classNames:Vector.<String>):void {
			for each (var className:String in classNames) {
				scan(className);
			}
		}

	}
}
