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
	import flash.utils.setTimeout;

	import flashx.textLayout.debug.assert;

	import org.as3commons.async.operation.event.OperationEvent;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.async.Async;

	public class TextFilesLoaderTest {

		private var _textFilesLoader:TextFilesLoader

		public function TextFilesLoaderTest() {
			super();
		}

		[Test(async, timeout="1000")]
		public function testLoadSingleFile():void {
			_textFilesLoader = new TextFilesLoader("singleFileTest");
			_textFilesLoader.addCompleteListener(handleSingleFileComplete);
			_textFilesLoader.addURI("testfile1.txt", false);
		}

		[Test(async, timeout="1000")]
		public function testLoadMultipleFiles():void {
			_textFilesLoader = new TextFilesLoader("multipleFileTest");
			_textFilesLoader.addCompleteListener(handleMultipleFileComplete);
			_textFilesLoader.addURI("testfile1.txt", false);
			_textFilesLoader.addURI("testfile2.txt", false);
			_textFilesLoader.addURI("testfile3.txt", false);
		}

		protected function handleSingleFileComplete(event:OperationEvent):void {
			var result:Vector.<String> = event.result;
			assertNotNull(result);
			assertEquals(1, result.length);
			assertEquals("test1", result[0]);
		}

		protected function handleMultipleFileComplete(event:OperationEvent):void {
			var result:Vector.<String> = event.result;
			assertNotNull(result);
			assertEquals(3, result.length);
			assertEquals("test1", result[0]);
			assertEquals("test2", result[1]);
			assertEquals("test3", result[2]);
		}
	}
}
