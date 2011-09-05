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
	import org.as3commons.lang.IOrdered;
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
	public class ObjectDefinitonFactoryPostProcessor extends AbstractOrderedFactoryPostProcessor {

		private static const IS_INTERFACE_FIELD_NAME:String = "isInterface";
		private static const PARENT_FIELD_NAME:String = "parent";
		private static const DESTROY_METHOD_FIELD_NAME:String = "destroyMethod";
		private static const FACTORY_METHOD_FIELD_NAME:String = "factoryMethod";
		private static const FACTORY_OBJECT_NAME_FIELD_NAME:String = "factoryObjectName";
		private static const INIT_METHOD_FIELD_NAME:String = "initMethod";

		/**
		 * Creates a new <code>ObjectDefinitonFactoryPostProcessor</code> instance.
		 */
		public function ObjectDefinitonFactoryPostProcessor(orderPosition:int) {
			super(orderPosition);
		}

		/**
		 *
		 * @param objectFactory
		 * @return
		 */
		override public function postProcessObjectFactory(objectFactory:IObjectFactory):IOperation {
			var registry:IObjectDefinitionRegistry = objectFactory.objectDefinitionRegistry;
			resolveParentDefinitions(registry);
			mergeParentDefinitions(registry, objectFactory.applicationDomain);
			mergeInterfaceDefinitions(registry, objectFactory.applicationDomain);
			return null;
		}

		/**
		 *
		 * @param registry
		 * @param applicationDomain
		 */
		public function mergeParentDefinitions(registry:IObjectDefinitionRegistry, applicationDomain:ApplicationDomain):void {
			var objectNames:Vector.<String> = registry.getDefinitionNamesWithPropertyValue(PARENT_FIELD_NAME, null, false);
			for each (var name:String in objectNames) {
				var objectDefinition:IObjectDefinition = registry.getObjectDefinition(name);
				mergeParentDefinition(registry, objectDefinition);
				mergeObjectDefinitions(objectDefinition.parent, objectDefinition);
			}
		}

		public function mergeParentDefinition(registry:IObjectDefinitionRegistry, objectDefinition:IObjectDefinition):void {
			copyConstructorArguments(objectDefinition, objectDefinition.parent);
			setParentProperty(objectDefinition, DESTROY_METHOD_FIELD_NAME)
			setParentProperty(objectDefinition, FACTORY_METHOD_FIELD_NAME)
			setParentProperty(objectDefinition, FACTORY_OBJECT_NAME_FIELD_NAME)
			setParentProperty(objectDefinition, INIT_METHOD_FIELD_NAME)
		}

		public function copyConstructorArguments(objectDefinition:IObjectDefinition, parentDefinition:IObjectDefinition):void {
			if ((objectDefinition.constructorArguments == null) && (parentDefinition.constructorArguments != null)) {
				objectDefinition.constructorArguments = parentDefinition.constructorArguments.concat([]);
			}
		}

		public function setParentProperty(objectDefinition:IObjectDefinition, propertyName:String):void {
			if (!StringUtils.hasText(objectDefinition[propertyName])) {
				objectDefinition[propertyName] = objectDefinition.parent[propertyName];
			}
		}

		/**
		 *
		 * @param registry
		 * @param applicationDomain
		 */
		public function mergeInterfaceDefinitions(registry:IObjectDefinitionRegistry, applicationDomain:ApplicationDomain):void {
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

		/**
		 *
		 * @param interfaceDefinition
		 * @param implementations
		 */
		public function mergeInterfaceDefinitionWithObjectDefinitions(interfaceDefinition:IObjectDefinition, implementations:Vector.<IObjectDefinition>):void {
			for each (var objectDefinition:IObjectDefinition in implementations) {
				mergeObjectDefinitions(interfaceDefinition, objectDefinition);
			}
		}

		/**
		 *
		 * @param sourceDefinition
		 * @param destinationDefinition
		 */
		public function mergeObjectDefinitions(sourceDefinition:IObjectDefinition, destinationDefinition:IObjectDefinition):void {
			mergeProperties(sourceDefinition, destinationDefinition);
			mergeMethodInvocations(sourceDefinition, destinationDefinition);
		}

		/**
		 *
		 * @param sourceDefinition
		 * @param destinationDefinition
		 */
		public function mergeMethodInvocations(sourceDefinition:IObjectDefinition, destinationDefinition:IObjectDefinition):void {
			for each (var methodInvocation:MethodInvocation in sourceDefinition.methodInvocations) {
				if (destinationDefinition.getMethodInvocationByName(methodInvocation.methodName, methodInvocation.namespaceURI) == null) {
					destinationDefinition.addMethodInvocation(methodInvocation);
				}
			}
		}

		/**
		 *
		 * @param sourceDefinition
		 * @param destinationDefinition
		 */
		public function mergeProperties(sourceDefinition:IObjectDefinition, destinationDefinition:IObjectDefinition):void {
			for each (var propertyDefinition:PropertyDefinition in sourceDefinition.properties) {
				if (destinationDefinition.getPropertyDefinitionByName(propertyDefinition.name, propertyDefinition.namespaceURI) == null) {
					destinationDefinition.addPropertyDefinition(PropertyDefinition(propertyDefinition.clone()));
				}
			}
		}

		/**
		 *
		 * @param objectNames
		 * @param interfaceClass
		 * @param registry
		 * @param applicationDomain
		 * @return
		 */
		public function getImplementations(objectNames:Vector.<String>, interfaceClass:Class, registry:IObjectDefinitionRegistry, applicationDomain:ApplicationDomain):Vector.<IObjectDefinition> {
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

		/**
		 *
		 * @param registry
		 */
		public function resolveParentDefinitions(registry:IObjectDefinitionRegistry):void {
			for each (var name:String in registry.objectDefinitionNames) {
				var objectDefinition:IObjectDefinition = registry.getObjectDefinition(name);
				if (StringUtils.hasText(objectDefinition.parentName)) {
					objectDefinition.parent = registry.getObjectDefinition(objectDefinition.parentName);
				}
			}
		}

	}
}
