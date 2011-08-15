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

	import flash.system.ApplicationDomain;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.StringUtils;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;

	/**
	 * Aggregates all <code>IObjectDefinitions</code> who have non-null parent and/or interfaceDefinitions properties
	 * and merges the referenced <code>IObjectDefinitions</code>.
	 * @author Roland Zwaga
	 */
	public class ObjectDefinitonFactoryPostProcessor implements IObjectFactoryPostProcessor {
		private static const IS_INTERFACE_FIELD_NAME:String = "isInterface";
		private static const PARENT_FIELD_NAME:String = "parent";

		/**
		 * Creates a new <code>ObjectDefinitonFactoryPostProcessor</code> instance.
		 */
		public function ObjectDefinitonFactoryPostProcessor() {
			super();
		}

		/**
		 *
		 * @param objectFactory
		 * @return
		 */
		public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation {
			var registry:IObjectDefinitionRegistry = objectFactory.objectDefinitionRegistry;
			resolveParentDefinitions(registry);
			mergeParentDefinitions(registry, objectFactory.applicationDomain);
			mergeInterfaceDefinitions(registry, objectFactory.applicationDomain);
			return null;
		}

		protected function mergeParentDefinitions(registry:IObjectDefinitionRegistry, applicationDomain:ApplicationDomain):void {
			var objectNames:Vector.<String> = registry.getDefinitionNamesWithPropertyValue(PARENT_FIELD_NAME, null, false);
			for each (var name:String in objectNames) {
				var objectDefinition:IObjectDefinition = registry.getObjectDefinition(name);
				if ((objectDefinition.constructorArguments == null) && (objectDefinition.parent.constructorArguments != null)) {
					objectDefinition.constructorArguments = objectDefinition.parent.constructorArguments.concat([]);
				}
				objectDefinition.autoWireMode = objectDefinition.parent.autoWireMode;
				objectDefinition.dependencyCheck = objectDefinition.parent.dependencyCheck;
				objectDefinition.destroyMethod = objectDefinition.parent.destroyMethod;
				objectDefinition.factoryMethod = objectDefinition.parent.factoryMethod;
				objectDefinition.factoryObjectName = objectDefinition.parent.factoryObjectName;
				objectDefinition.initMethod = objectDefinition.parent.initMethod;
				objectDefinition.scope = objectDefinition.parent.scope;
				mergeObjectDefinitions(objectDefinition.parent, objectDefinition);
			}
		}

		protected function mergeInterfaceDefinitions(registry:IObjectDefinitionRegistry, applicationDomain:ApplicationDomain):void {
			var interfaces:Vector.<String> = registry.getDefinitionNamesWithPropertyValue(IS_INTERFACE_FIELD_NAME, true);
			var objects:Vector.<String> = registry.getDefinitionNamesWithPropertyValue(IS_INTERFACE_FIELD_NAME, false);
			if ((interfaces != null) && (objects != null)) {
				for each (var interfaceName:String in interfaces) {
					var interfaceDefinition:IObjectDefinition = registry.getObjectDefinition(interfaceName);
					var cls:Class = interfaceDefinition.clazz;
					var implementations:Vector.<IObjectDefinition> = getImplementations(objects, cls, registry, applicationDomain);
					mergeInterfaceDefinitionWithObjectDefinitions(interfaceDefinition, implementations);
				}
			}
		}

		protected function mergeInterfaceDefinitionWithObjectDefinitions(interfaceDefinition:IObjectDefinition, implementations:Vector.<IObjectDefinition>):void {
			for each (var objectDefinition:IObjectDefinition in implementations) {
				mergeObjectDefinitions(interfaceDefinition, objectDefinition);
			}
		}

		protected function mergeObjectDefinitions(sourceDefinition:IObjectDefinition, destinationDefinition:IObjectDefinition):void {
			mergeProperties(sourceDefinition, destinationDefinition);
			mergeMethodInvocations(sourceDefinition, destinationDefinition);
		}

		protected function mergeMethodInvocations(sourceDefinition:IObjectDefinition, destinationDefinition:IObjectDefinition):void {
			for each (var methodInvocation:MethodInvocation in sourceDefinition.methodInvocations) {
				if (destinationDefinition.getMethodInvocationByName(methodInvocation.methodName, methodInvocation.namespaceURI) == null) {
					destinationDefinition.addMethodInvocation(methodInvocation);
				}
			}
		}

		protected function mergeProperties(sourceDefinition:IObjectDefinition, destinationDefinition:IObjectDefinition):void {
			for each (var propertyDefinition:PropertyDefinition in sourceDefinition.properties) {
				if (destinationDefinition.getPropertyDefinitionByName(propertyDefinition.name, propertyDefinition.namespaceURI) == null) {
					destinationDefinition.addPropertyDefinition(PropertyDefinition(propertyDefinition.clone()));
				}
			}
		}

		protected function getImplementations(objectNames:Vector.<String>, interfaceClass:Class, registry:IObjectDefinitionRegistry, applicationDomain:ApplicationDomain):Vector.<IObjectDefinition> {
			var result:Vector.<IObjectDefinition>;
			for each (var objectName:String in objectNames) {
				var definition:IObjectDefinition = registry.getObjectDefinition(objectName);
				if (ClassUtils.isImplementationOf(definition.clazz, interfaceClass, applicationDomain)) {
					result ||= new Vector.<IObjectDefinition>();
					result[result.length] = definition;
				}
			}
			return result;
		}

		protected function resolveParentDefinitions(registry:IObjectDefinitionRegistry):void {
			for each (var name:String in registry.objectDefinitionNames) {
				var objectDefinition:IObjectDefinition = registry.getObjectDefinition(name);
				if (StringUtils.hasText(objectDefinition.parentName)) {
					objectDefinition.parent = registry.getObjectDefinition(objectDefinition.parentName);
				}
			}
		}


	}
}
