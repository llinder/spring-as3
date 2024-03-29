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
package org.springextensions.actionscript.metadata {

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.lang.Assert;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.metadata.process.IMetadataProcessor;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;

	/**
	 * <code>IObjectFactoryPostProcessor</code> implementation that checks if the specified <code>objectFactory</code>
	 * contains a <code>MetadataProcessorObjectPostProcessor</code>, if not it creates an instance and registers it
	 * with the factory.
	 * @author Roland Zwaga
	 */
	public class MetadataProcessorObjectFactoryPostProcessor implements IObjectFactoryPostProcessor {

		// --------------------------------------------------------------------
		//
		// Private Static Variables
		//
		// --------------------------------------------------------------------

		private static var logger:ILogger = getLogger(MetadataProcessorObjectFactoryPostProcessor);

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>MetadataProcessorObjectFactoryPostProcessor</code> instance.
		 */
		public function MetadataProcessorObjectFactoryPostProcessor() {
			super();
		}

		// --------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------

		/**
		 * Registers an <code>ObjectDefinition</code> for a <code>MetadataProcessorObjectPostProcessor</code> instance
		 * with the specified <code>IConfigurableListableObjectFactory</code>.
		 * @param objectFactory The specified <code>IConfigurableListableObjectFactory</code>.
		 */
		public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation {
			Assert.notNull(objectFactory, "objectFactory argument must not be null");

			var names:Vector.<String> = objectFactory.objectDefinitionRegistry.getObjectNamesForType(IMetaDataProcessorObjectPostProcessor);
			var noMetadataProcessorObjectPostProcessorRegistered:Boolean = (names == null);
			names = objectFactory.objectDefinitionRegistry.getObjectNamesForType(IMetadataProcessor);
			var metadataProcessorsRegistered:Boolean = (names != null);

			if ((noMetadataProcessorObjectPostProcessorRegistered) && (metadataProcessorsRegistered == true)) {
				logger.debug("No MetadataProcessorObjectPostProcessor found in the object factory, registering MetadataProcessorObjectPostProcessor");
				objectFactory.addObjectPostProcessor(objectFactory.createInstance(MetadataProcessorObjectPostProcessor));
			}
			return null;
		}
	}
}
