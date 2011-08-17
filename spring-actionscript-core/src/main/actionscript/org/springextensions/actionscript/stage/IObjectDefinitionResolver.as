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
package org.springextensions.actionscript.stage {

	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;

	/**
	 * Objects implementing this interface are used to retrieve an <code>IObjectDefinition</code>
	 * for already existing objects to be wired. Useful for <code>IDependencyInjector</code> that
	 * have to deal with already existing objects and can't use factory methods.
	 *
	 * <p>
	 * <b>Author:</b> Martino Piccinato<br/>
	 * <b>Version:</b> $Revision:$, $Date:$, $Author:$<br/>
	 * <b>Since:</b> 0.8
	 * </p>
	 *
	 * @see org.springextensions.actionscript.ioc.IDependencyInjector
	 * @see org.springextensions.actionscript.context.support.FlexXMLApplicationContext
	 * @docref container-documentation.html#how_to_determine_which_objectdefinition_to_use_for_which_stage_component
	 * @sampleref stagewiring
	 */
	public interface IObjectDefinitionResolver {

		/**
		 * Resolve an <code>IObjectDefinition</code> for an object to be subsequently
		 * wired.
		 *
		 * @param object The object to be wired.
		 *
		 * @return the <code>IObjectDefinition</code> to be used to wire the passed object.
		 */
		function resolveObjectDefinition(object:*):org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;

	}
}
