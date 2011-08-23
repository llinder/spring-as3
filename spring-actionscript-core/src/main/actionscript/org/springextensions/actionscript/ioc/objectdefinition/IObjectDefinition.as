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
package org.springextensions.actionscript.ioc.objectdefinition {
	import org.springextensions.actionscript.ioc.autowire.AutowireMode;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;

	/**
	 * Represents an object definition.
	 *
	 * @author Christophe Herreman
	 * @author Damir Murat
	 * @author Roland Zwaga
	 */
	public interface IObjectDefinition {

		/**
		 * Defines the way an object will be autowired (configured).
		 */
		function get autoWireMode():AutowireMode;
		/**
		 * @private
		 */
		function set autoWireMode(value:AutowireMode):void;

		/**
		 * Determines if the current <code>IObjectDefinition</code> will be injected into child contexts.
		 */
		function get childContextAccess():ChildContextObjectDefinitionAccess;

		/**
		 * @private
		 */
		function set childContextAccess(value:ChildContextObjectDefinitionAccess):void;

		/**
		 * The classname of the object that the current <code>IObjectDefinition</code> describes.
		 */
		function get className():String;
		/**
		 * @private
		 */
		function set className(value:String):void;

		/**
		 * The <code>Class</code> of the object that the current <code>IObjectDefinition</code> describes.
		 */
		function get clazz():Class;
		/**
		 * @private
		 */
		function set clazz(value:Class):void;

		/**
		 * An array of arguments that will be passed to the constructor of the object.
		 */
		function get constructorArguments():Array;
		/**
		 * @private
		 */
		function set constructorArguments(value:Array):void;

		/**
		 * Optional extra data that can be used by other processing logic.
		 */
		function get customConfiguration():*;
		/**
		 * @private
		 */
		function set customConfiguration(value:*):void;

		/**
		 * Determines if and how the object properties dependencies should be checked.
		 */
		function get dependencyCheck():DependencyCheckMode;

		/**
		 * @private
		 */
		function set dependencyCheck(value:DependencyCheckMode):void;

		/**
		 * Returns the object names that this object depends on.
		 */
		function get dependsOn():Vector.<String>;

		/**
		 * Sets the object names that this object depends on. The object factory will guarantee that the dependent
		 * objects will be created before this object gets created.
		 */
		function set dependsOn(value:Vector.<String>):void;

		/**
		 * The name of a method on the class defined by the <code>className</code> property that will be called when the
		 * application context is disposed. Destroy methods are used to release resources that are being kept by an object.
		 */
		function get destroyMethod():String;
		/**
		 * @private
		 */
		function set destroyMethod(value:String):void;

		/**
		 * The name of method responsible for the creation of the object. This is either a static method of class defined
		 * by the <code>className</code> property or the name of a method on the object defined by the <code>factoryObjectName</code> property.
		 */
		function get factoryMethod():String;
		/**
		 * @private
		 */
		function set factoryMethod(value:String):void;

		/**
		 * The name of the factory object responsible for the creation of the object.
		 */
		function get factoryObjectName():String;
		/**
		 * @private
		 */
		function set factoryObjectName(value:String):void;

		/**
		 * The name of a method on the class defined by the <code>className</code> property that will be called immediately after the
		 * object has been configured.
		 */
		function get initMethod():String;
		/**
		 * @private
		 */
		function set initMethod(value:String):void;

		/**
		 *
		 */
		function get isAbstract():Boolean;

		/**
		 * @private
		 */
		function set isAbstract(value:Boolean):void;

		/**
		 * True if this object can be used as a value used by the container when it autowires an object by type.
		 */
		function get isAutoWireCandidate():Boolean;
		/**
		 * @private
		 */
		function set isAutoWireCandidate(value:Boolean):void;

		/**
		 * Determines if the class whose configuration is described by the current <code>IObjectDefinition</code> is an interface;
		 */
		function get isInterface():Boolean;

		/**
		 * @private
		 */
		function set isInterface(value:Boolean):void;

		/**
		 *  True if the object does not need to be eagerly pre-instantiated by the container. I.e. the object will be created
		 *  after the first call to the <code>getObject()</code> method.
		 *  @see org.springextensions.actionscript.ioc.factory.IObjectFactory#getObject() IObjectFactory.getObject()
		 */
		function get isLazyInit():Boolean;
		/**
		 * @private
		 */
		function set isLazyInit(value:Boolean):void;

		/**
		 * True if only one instance of this object needs to be created by the container, i.e. every subsequent call to the <code>getObject()</code>
		 * method will return the same instance.
		 * @see org.springextensions.actionscript.ioc.factory.IObjectFactory#getObject() IObjectFactory.getObject()
		 */
		function get isSingleton():Boolean;
		/**
		 * @private
		 */
		function set isSingleton(value:Boolean):void;

		/**
		 * Defines the method invocations executed after an object from this definition is created.
		 */
		function get methodInvocations():Vector.<MethodInvocation>;

		/**
		 * An <code>IObjectDefinition</code> whose properties will be inherited by the current <code>IObjectDefinition</code>.
		 */
		function get parent():IObjectDefinition;
		/**
		 * @private
		 */
		function set parent(value:IObjectDefinition):void;

		/**
		 * The name of an <code>IObjectDefinition</code> whose properties will be inherited by the current <code>IObjectDefinition</code>.
		 */
		function get parentName():String;
		/**
		 * @private
		 */
		function set parentName(value:String):void;

		/**
		 * True if this object needs to be used as the primary autowire candidate when the container is autowiring by type.
		 * This means that if multiple objects are found of the same type, the object marked as 'primary' will become the
		 * autowire candidate.
		 */
		function get primary():Boolean;
		/**
		 * @private
		 */
		function set primary(value:Boolean):void;

		/**
		 * An anonymous object whose property values will be injected into the created object, the property names
		 * on this object are the same as on the created object.
		 */
		function get properties():Vector.<PropertyDefinition>;

		/**
		 * The id of the <code>IObjectDefinitionRegistry</code> that the current <code>IObjectDefinition</code> was first registered with.
		 */
		function get registryId():String;
		/**
		 * @private
		 */
		function set registryId(value:String):void;

		/**
		 * Defines the scope of the object, the object is either a singleton, a prototype or a stage object.
		 */
		function get scope():ObjectDefinitionScope;
		/**
		 * @private
		 */
		function set scope(value:ObjectDefinitionScope):void;

		/**
		 * Determines whether the autowire processor will examine the class metadata.
		 */
		function get skipMetadata():Boolean;
		/**
		 * @private
		 */
		function set skipMetadata(value:Boolean):void;

		/**
		 * Determines whether the object factory will send the created object through its list of <code>IObjectProcessors</code>.
		 */
		function get skipPostProcessors():Boolean;
		/**
		 * @private
		 */
		function set skipPostProcessors(value:Boolean):void;

		/**
		 *
		 * @param methodInvocation
		 */
		function addMethodInvocation(methodInvocation:MethodInvocation):void;

		/**
		 *
		 * @param propertyDefinition
		 */
		function addPropertyDefinition(propertyDefinition:PropertyDefinition):void;

		/**
		 *
		 * @param name
		 * @param namespace
		 * @return
		 *
		 */
		function getMethodInvocationByName(name:String, namespace:String=null):MethodInvocation;

		/**
		 *
		 * @param name
		 * @param namespace
		 * @return
		 */
		function getPropertyDefinitionByName(name:String, namespace:String=null):PropertyDefinition;
	}
}
