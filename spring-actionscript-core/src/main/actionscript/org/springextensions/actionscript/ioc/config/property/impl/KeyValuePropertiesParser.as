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

	import org.as3commons.lang.StringUtils;
	import org.springextensions.actionscript.util.MultilineString;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesParser;

	/**
	 * <p><code>KeyValuePropertiesParser</code> parses a properties source string into a <code>IPropertiesProvider</code>
	 * instance.</p>
	 *
	 * <p>The source string contains simple key-value pairs. Multiple pairs are
	 * separated by line terminators (\n or \r or \r\n). Keys are separated from
	 * values with the characters '=', ':' or a white space character.</p>
	 *
	 * <p>Comments are also supported. Just add a '#' or '!' character at the
	 * beginning of your comment-line.</p>
	 *
	 * <p>If you want to use any of the special characters in your key or value you
	 * must escape it with a back-slash character '\'.</p>
	 *
	 * <p>The key contains all of the characters in a line starting from the first
	 * non-white space character up to, but not including, the first unescaped
	 * key-value-separator.</p>
	 *
	 * <p>The value contains all of the characters in a line starting from the first
	 * non-white space character after the key-value-separator up to the end of the
	 * line. You may of course also escape the line terminator and create a value
	 * across multiple lines.</p>
	 *
	 * @see org.springextensions.actionscript.collections.Properties Properties
	 *
	 * @author Martin Heidegger
	 * @author Simon Wacker
	 * @author Christophe Herreman
	 * @version 1.0
	 */
	public class KeyValuePropertiesParser implements IPropertiesParser {

		private static const HASH:String = "#";
		private static const EXCLAMATION_MARK:String = "!";

		/**
		 * Constructs a new <code>PropertiesParser</code> instance.
		 */
		public function KeyValuePropertiesParser() {
			super();
		}

		/**
		 * Parses the given <code>source</code> and creates a <code>Properties</code> instance from it.
		 *
		 * @param source the source to parse
		 * @return the properties defined by the given <code>source</code>
		 */
		public function parseProperties(source:*):IPropertiesProvider {
			var result:IPropertiesProvider = new Properties();
			var lines:MultilineString = new MultilineString(String(source));
			var numLines:Number = lines.numLines;
			var key:String;
			var value:String;
			var formerKey:String;
			var formerValue:String;
			var useNextLine:Boolean = false;

			for (var i:int = 0; i < numLines; i++) {
				var line:String = lines.getLine(i);
				// Trim the line
				line = StringUtils.trim(line);

				// Ignore Comments
				if (line.indexOf(HASH) != 0 && line.indexOf(EXCLAMATION_MARK) != 0 && line.length != 0) {
					// Line break processing
					if (useNextLine) {
						key = formerKey;
						value = formerValue + line;
						useNextLine = false;
					} else {
						var sep:Number = getSeparation(line);
						key = StringUtils.rightTrim(line.substr(0, sep));
						value = line.substring(sep + 1);
						formerKey = key;
						formerValue = value;
					}
					// Trim the content
					value = StringUtils.leftTrim(value);

					// Allow normal lines
					if (value.charAt(value.length - 1) == "\\") {
						formerValue = value = value.substr(0, value.length - 1);
						useNextLine = true;
					} else {
						// restore newlines since these were escaped when loaded
						value = value.replace(/\\n/gm, "\n");
						result.setProperty(key, value);
					}
				}
			}
			return result;
		}

		/**
		 * Returns the position at which key and value are separated.
		 *
		 * @param line the line that contains the key-value pair
		 * @return the position at which key and value are separated
		 */
		protected function getSeparation(line:String):int {
			var len:int = line.length;

			for (var i:int = 0; i < len; i++) {
				var char:String = line.charAt(i);

				if (char == "'") {
					i++;
				} else {
					if (char == ":" || char == "=" || char == "	") {
						break;
					}
				}
			}
			return ((i == len) ? line.length : i);
		}

	}

}
