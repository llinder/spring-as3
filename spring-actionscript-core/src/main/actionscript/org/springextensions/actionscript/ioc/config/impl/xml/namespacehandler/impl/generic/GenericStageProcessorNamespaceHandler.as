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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.generic {

	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractNamespaceHandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.generic.nodeparser.GenericStageProcessorNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_stageprocessing;

	/**
	 * Namespace handler for all elements pertaining to the stage interception schema
	 * @author Roland Zwaga
	 * @docref xml-schema-based-configuration.html#the_stage_interception_schema
	 */
	public class GenericStageProcessorNamespaceHandler extends AbstractNamespaceHandler {

		public static const GENERIC_STAGE_PROCESSOR_ELEMENT:String = "genericstageprocessor";

		public function GenericStageProcessorNamespaceHandler() {
			super(spring_actionscript_stageprocessing);
			registerObjectDefinitionParser(GENERIC_STAGE_PROCESSOR_ELEMENT, new GenericStageProcessorNodeParser());
		}
	}
}
