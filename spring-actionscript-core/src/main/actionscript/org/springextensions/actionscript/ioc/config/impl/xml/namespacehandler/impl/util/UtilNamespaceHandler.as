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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.util {

	import flash.system.ApplicationDomain;

	import org.as3commons.lang.IApplicationDomainAware;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.AbstractNamespaceHandler;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.util.nodeparser.ConstantNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.util.nodeparser.FactoryNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.util.nodeparser.InvokeNodeParser;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_util;
	import org.springextensions.actionscript.ioc.factory.IInitializingObject;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistryAware;

	/**
	 * Util namespace handler.
	 * xml-schema-based-configuration.html#the_util_schema
	 * @author Christophe Herreman
	 * @author Roland Zwaga
	 */
	public class UtilNamespaceHandler extends AbstractNamespaceHandler implements IObjectDefinitionRegistryAware, IApplicationDomainAware, IInitializingObject {

		public static const CONSTANT:String = "constant";

		public static const INVOKE:String = "invoke";

		public static const FACTORY:String = "factory";
		private var _applicationDomain:ApplicationDomain;
		private var _objectDefinitionRegistry:IObjectDefinitionRegistry;

		/**
		 * Creates a new <code>UtilNamespaceHandler</code> instance.
		 */
		public function UtilNamespaceHandler() {
			super(spring_actionscript_util);
		}

		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}

		public function afterPropertiesSet():void {
			registerObjectDefinitionParser(CONSTANT, new ConstantNodeParser());
			registerObjectDefinitionParser(INVOKE, new InvokeNodeParser());
			registerObjectDefinitionParser(FACTORY, new FactoryNodeParser(_objectDefinitionRegistry, _applicationDomain));
		}

		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _objectDefinitionRegistry;
		}

		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_objectDefinitionRegistry = value;
		}
	}
}
