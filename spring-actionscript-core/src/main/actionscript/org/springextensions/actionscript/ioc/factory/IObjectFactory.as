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
package org.springextensions.actionscript.ioc.factory {
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;

	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.impl.Properties;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistryAware;

	/**
	 * Describes an object that is capable of creating and configuring instances of other classes.
	 * @author Christophe Herreman
	 * @author Roland Zwaga
	 */
	public interface IObjectFactory extends IObjectDefinitionRegistryAware, IEventDispatcher {

		/**
		 *
		 * @param objectPostProcessor
		 */
		function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):void;

		/**
		 *
		 * @param referenceResolver
		 */
		function addReferenceResolver(referenceResolver:IReferenceResolver):void;

		/**
		 * The <code>ApplicationDomain</code> that is associated with the current <code>IObjectFactory</code>
		 */
		function get applicationDomain():ApplicationDomain;
		/**
		 * @private
		 */
		function set applicationDomain(value:ApplicationDomain):void;

		/**
		 * An <code>IInstanceCache</code> instance used to hold the singletons created by the current <code>IObjectFactory</code>.
		 */
		function get cache():IInstanceCache;

		/**
		 * Creates an instance of the specified <code>Class</code>, wires the instance and returns it.
		 * Useful for creating objects that have only been annotated with [Autowired] metadata and need
		 * no object definition.
		 * @param clazz The specified <code>Class</code>.
		 * @param constructorArguments Optional <code>Array</code> of constructor arguments to be used for the instance.
		 * @return The created and wired instance of the specified <code>Class</code>.
		 */
		function createInstance(clazz:Class, constructorArguments:Array=null):*;

		/**
		 *
		 */
		function get dependencyInjector():IDependencyInjector;

		/**
		 * @private
		 */
		function set dependencyInjector(value:IDependencyInjector):void;
		/**
		 * Will retrieve an object by it's name/id If the definition is a singleton it will be retrieved from
		 * cache if possible. If the definition defines an init method, the init method will be called after
		 * all properties have been set.
		 * <p />
		 * If any object post processors are defined they will be run against the newly created instance.
		 * <p />
		 * The class that is instantiated can implement the following interfaces for a special treatment: <br />
		 * <ul>
		 *   <li><code>IInitializingObject</code>: The method defined by the interface will called after the
		 *                       properties have been set.</li>
		 *   <li><code>IFactoryObject</code>:    The actual object will be retrieved using the getObject method.</li>
		 * </ul>
		 *
		 * @param name            The name of the object as defined in the object definition
		 * @param constructorArguments    The arguments that should be passed to the constructor. Note that
		 *                   the constructorArguments can only be passed if the object is
		 *                   defined as lazy.
		 *
		 * @return An instance of the requested object
		 *
		 * @see #resolveReference()
		 * @see org.springextensions.actionscript.ioc.IObjectDefinition
		 * @see org.springextensions.actionscript.ioc.factory.config.IObjectPostProcessor
		 * @see org.springextensions.actionscript.ioc.factory.IInitializingObject
		 * @see org.springextensions.actionscript.ioc.factory.IFactoryObject
		 *
		 * @throws org.springextensions.actionscript.ioc.ObjectDefinitionNotFoundError    The name of the given object should be
		 *                                   present as an object definition
		 * @throws flash.errors.IllegalOperationError            A singleton object definition that is not lazy
		 *                                   can not be given constructor arguments
		 * @throws org.springextensions.actionscript.errors.PropertyTypeError        The type of a property definition should
		 *                                   match the type of property on the instance
		 * @throws org.springextensions.actionscript.errors.ClassNotFoundError        The class set on the definition should
		 *                                   be compiled into the application
		 * @throws org.springextensions.actionscript.errors.ResolveReferenceError      Indicating a problem resolving the
		 *                                   references of a certain property
		 *
		 * @example The following code retrieves an object named "myPerson" from the object factory:
		 * <listing version="3.0">
		 *   var myPerson:Person = objectFactory.getObject("myPerson");
		 * </listing>
		 */
		function getObject(name:String, constructorArguments:Array=null):*;

		/**
		 *
		 */
		function getObjectDefinition(objectName:String):IObjectDefinition;

		/**
		 * Returns <code>true</code> when the current <code>IObjectFactory</code> is fully initialized and ready for use.
		 */
		function get isReady():Boolean;

		/**
		 * @private
		 */
		function set isReady(value:Boolean):void;

		/**
		 *
		 */
		function get objectPostProcessors():Vector.<IObjectPostProcessor>;

		/**
		 * Optional parent factory that can be used to create objects that can't be created by the current instance.
		 */
		function get parent():IObjectFactory;

		/**
		 * @private
		 */
		function set parent(value:IObjectFactory):void;

		/**
		 *
		 */
		function get propertiesProvider():IPropertiesProvider;
		/**
		 * @private
		 */
		function set propertiesProvider(value:IPropertiesProvider):void;

		/**
		 */
		function get referenceResolvers():Vector.<IReferenceResolver>;

		/**
		 *
		 * @param property
		 * @return
		 *
		 */
		function resolveReference(property:*):*;

	}
}
