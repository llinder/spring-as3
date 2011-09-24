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
package org.springextensions.actionscript.util {
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.reflect.Metadata;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;

	public final class ContextUtils {

		public static const COMMA:String = ',';

		public static function disposeInstance(instance:Object):void {
			if (instance is IDisposable) {
				IDisposable(instance).dispose();
			}
		}

		public static function getCustomConfigurationForObjectName(instance:String, objectDefinitionRegistry:IObjectDefinitionRegistry):Vector.<ICustomConfigurator> {
			var config:* = objectDefinitionRegistry.getCustomConfiguration(instance);
			var customConfiguration:Vector.<ICustomConfigurator> = (config is Vector.<ICustomConfigurator>) ? (config as Vector.<ICustomConfigurator>) : new Vector.<ICustomConfigurator>();
			if ((config != null) && !(config is Vector.<ICustomConfigurator>)) {
				customConfiguration[customConfiguration.length] = config;
			}
			return customConfiguration;
		}

		public static function commaSeparatedPropertyValueToStringVector(propertyValue:String):Vector.<String> {
			if (StringUtils.hasText(propertyValue)) {
				var parts:Array = propertyValue.split(COMMA);
				var result:Vector.<String> = new Vector.<String>();
				for each (var name:String in parts) {
					result[result.length] = StringUtils.trim(name);
				}
				return result;
			}
			return null;
		}

		public static function getMetadataArgument(metadata:Metadata, key:String):String {
			if (metadata.hasArgumentWithKey(key)) {
				return metadata.getArgument(key).value;
			}
			return null;
		}

		public static function getCommaSeparatedArgument(metadata:Metadata, key:String):Vector.<String> {
			if (metadata.hasArgumentWithKey(key)) {
				commaSeparatedPropertyValueToStringVector(metadata.getArgument(key).value);
			}
			return null;
		}

	}
}
