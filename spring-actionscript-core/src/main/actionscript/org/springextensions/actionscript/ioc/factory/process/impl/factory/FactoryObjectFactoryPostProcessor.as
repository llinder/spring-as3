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

	import flash.errors.IllegalOperationError;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.reflect.Metadata;
	import org.as3commons.reflect.Type;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.impl.GenericFactoryObject;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;

	/**
	 *
	 * @author rolandzwaga
	 */
	public class FactoryObjectFactoryPostProcessor implements IObjectFactoryPostProcessor {
		private static const FACTORY_METADATA_NAME:String = "Factory";
		private static const FACTORY_METHOD_FIELD_NAME:String = "factoryMethod";

		/**
		 * Creates a new <code>FactoryObjectFactoryPostProcessor</code> instance.
		 */
		public function FactoryObjectFactoryPostProcessor() {
			super();
		}

		public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation {
			var names:Vector.<String> = new Vector.<String>();
			names[names.length] = FACTORY_METADATA_NAME;
			var definitions:Vector.<IObjectDefinition> = objectFactory.objectDefinitionRegistry.getObjectDefinitionsWithMetadata(names);
			for each (var definition:IObjectDefinition in definitions) {
				var name:String = objectFactory.objectDefinitionRegistry.getObjectDefinitionName(definition);
				definition.isSingleton = true;
				var instance:Object = objectFactory.getObject(name);
				var type:Type = Type.forInstance(instance, objectFactory.applicationDomain);
				var md:Metadata = type.getMetadata(FACTORY_METADATA_NAME)[0];
				if (md.hasArgumentWithKey(FACTORY_METHOD_FIELD_NAME)) {
					var methodName:String = md.getArgument(FACTORY_METHOD_FIELD_NAME).value;
					var genericFactory:GenericFactoryObject = new GenericFactoryObject(instance, methodName);
					if (objectFactory.cache.hasInstance(name)) {
						objectFactory.cache.removeInstance(name);
					}
					objectFactory.cache.addInstance(name, genericFactory);
				} else {
					throw new IllegalOperationError(StringUtils.substitute("Class {0} contains [Factory] metadata but no factoryMethod argumnt", definition.clazz));
				}
			}
			return null;
		}
	}
}
