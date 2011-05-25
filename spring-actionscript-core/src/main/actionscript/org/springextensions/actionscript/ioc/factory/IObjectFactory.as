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

	import flash.system.ApplicationDomain;

	import org.as3commons.eventbus.IEventBusAware;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.factory.postprocess.IObjectPostProcessor;

	/**
	 * Describes an object that is capable of creating instances of other classes..
	 *
	 * @author Christophe Herreman
	 * @author Roland Zwaga
	 */
	public interface IObjectFactory extends IDependencyInjector, IEventBusAware, IApplicationDomainAware {

		/**
		 * Optional parent factory that can be used to create objects that can't be created by the current instance.
		 */
		function get parent():IObjectFactory;

		/**
		 * @private
		 */
		function set parent(value:IObjectFactory):void;

		/**
		 * A registry of object definitions that describe the way an <code>IObjectFactory</code> will have to
		 * create and configure objects.
		 */
		function get objectDefinitions():Object;

		/**
		 *
		 * @return
		 */
		function get applicationDomain():ApplicationDomain;

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
		 * @throws flash.errors.IllegalOperationError            An object definition that is not lazy
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
		function getObject(name:String, constructorArguments:Array = null):*;

		/**
		 * Creates an instance of the specified <code>Class</code>, wires the instance and returns it.
		 * Useful for creating objects that have only been annotated with [Autowired] metadata and need
		 * no object definition.
		 * @param clazz The specified <code>Class</code>.
		 * @param constructorArguments Optional <code>Array</code> of constructor arguments to be used for the instance.
		 * @return The created and wired instance of the specified <code>Class</code>.
		 */
		function createInstance(clazz:Class, constructorArguments:Array = null):*;

		/**
		 * Determines if the object factory is able to create the object with the given name.
		 * This does not necesarrily mean that the current <code>IObjectFactory</code> contains an
		 * object definition for the given name. If a parent factory is assigned this will be checked
		 * as well if the current factory does not contain the necessary object definition.
		 *
		 * @param objectName  The name/id  of the object definition
		 *
		 * @return true if the current <code>IObjectFactory</code> is able to create the object with the given name
		 *
		 * @see org.springextensions.actionscript.ioc.IObjectDefinition
		 */
		function canCreate(objectName:String):Boolean;

		/**
		 * Removes an object from the internal object instance cache. This cache is used
		 * to cache singletons.
		 *
		 * @param name     The name/id  of the object to remove
		 *
		 * @return       the removed object
		 */
		function clearObjectFromInternalCache(name:String):Object;

		/**
		 *
		 * @return
		 */
		function get properties():IPropertiesProvider;

		/**
		 * Returns <code>true</code> when the current <code>IObjectFactory</code> is ready for use.
		 */
		function get isReady():Boolean;

	}
}
