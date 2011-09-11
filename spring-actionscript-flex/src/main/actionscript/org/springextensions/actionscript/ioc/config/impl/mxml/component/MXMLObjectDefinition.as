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
package org.springextensions.actionscript.ioc.config.impl.mxml.component {
	import flash.errors.IllegalOperationError;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	import mx.core.IMXMLObject;
	import mx.utils.UIDUtil;

	import org.as3commons.lang.Assert;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.StringUtils;
	import org.springextensions.actionscript.ioc.autowire.AutowireMode;
	import org.springextensions.actionscript.ioc.config.impl.RuntimeObjectReference;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.ChildContextObjectDefinitionAccess;
	import org.springextensions.actionscript.ioc.objectdefinition.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.ObjectDefinitionScope;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;

	[DefaultProperty("childContent")]
	/**
	 * <p>MXML representation of an <code>ObjectDefinition</code> object. This non-visual component must be declared as
	 * a child component of a <code>MXMLApplicationContext</code> component.</p>
	 * <p>Describes an object that can populate an IObjectDefinition instance with properties defined in MXML.</p>
	 * @see org.springextensions.actionscript.context.support.MXMLApplicationContext MXMLApplicationContext
	 * @author Roland Zwaga
	 */
	public class MXMLObjectDefinition implements IMXMLObject, IApplicationDomainAware {

		/**
		 * Prefix added to <code>ObjectDefinitions</code> without an explicit context id, this prefix is needed
		 * by the MXMLUtils serializer
		 * @see org.springextensions.actionscript.utils.MXMLUtils#serializeMXMLApplicationContext() serializeMXMLApplicationContext()
		 */
		public static const ANON_OBJECT_PREFIX:String = "anonref_";
		private static const PARENT_DOCUMENT_FIELD_NAME:String = "parentDocument";
		private static const PARENT_OBJECT_FIELD_NAME:String = 'parentObject';
		private static const CLAZZ_FIELD_NAME:String = 'clazz';
		private static const CLASS_NAME_FIELD_NAME:String = 'className';
		private static const FACTORY_OBJECT_FIELD_NAME:String = 'factoryObject';
		private static const FACTORY_OBJECT_NAME_FIELD_NAME:String = 'factoryObjectName';
		private static const FACTORY_METHOD_FIELD_NAME:String = 'factoryMethod';
		private static const INIT_METHOD_FIELD_NAME:String = 'initMethod';
		private static const IS_SINGLETON_FIELD_NAME:String = 'isSingleton';
		private static const SCOPE_FIELD_NAME:String = 'scope';
		private static const IS_LAZY_INIT_FIELD_NAME:String = 'isLazyInit';
		private static const IS_ABSTRACT_FIELD_NAME:String = 'isAbstract';
		private static const IS_AUTO_WIRE_CANDIDATE_FIELD_NAME:String = 'isAutoWireCandidate';
		private static const AUTO_WIRE_MODE_FIELD_NAME:String = 'autoWireMode';
		private static const PRIMARY_FIELD_NAME:String = 'primary';
		private static const SKIP_POST_PROCESSORS_FIELD_NAME:String = 'skipPostProcessors';
		private static const SKIP_METADATA_FIELD_NAME:String = 'skipMetadata';
		private static const DEPENDENCY_CHECK_FIELD_NAME:String = 'dependencyCheck';
		private static const DESTROY_METHOD_FIELD_NAME:String = 'destroyMethod';
		private static const CLASS_TYPE_ATTR_NAME:String = "class";

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>ObjectDefinition</code> instance
		 *
		 */
		public function MXMLObjectDefinition() {
			super();
			initMXMLObjectDefinition();
		}

		protected var _isInitialized:Boolean = false;
		private var _applicationDomain:ApplicationDomain;
		private var _childContent:Array;
		private var _defaultedProperties:Dictionary;
		private var _definition:IObjectDefinition;
		private var _dependsOn:Array = [];
		private var _document:Object;
		private var _explicitProperties:Dictionary;
		private var _factoryObject:MXMLObjectDefinition;
		private var _id:String;
		private var _methodDefinitions:Dictionary;
		private var _objectDefinitions:Object;
		private var _params:Dictionary;
		private var _parentObject:MXMLObjectDefinition;

		// --------------------------------------------------------------------
		// Properties
		// --------------------------------------------------------------------



		public function get childContextAccess():String {
			return _definition.childContextAccess.value;
		}

		[Inspectable(enumeration="none,definition,singleton,full", defaultValue="full")]
		public function set childContextAccess(value:String):void {
			_definition.childContextAccess = ChildContextObjectDefinitionAccess.fromValue(value);
		}

		public function get isAbstract():Boolean {
			return _definition.isAbstract;
		}

		public function set isAbstract(value:Boolean):void {
			_definition.isAbstract = value;
			delete _defaultedProperties[IS_ABSTRACT_FIELD_NAME];
			_explicitProperties[IS_ABSTRACT_FIELD_NAME] = true;
		}

		/**
		 * @private
		 */
		public function get applicationDomain():ApplicationDomain {
			return _applicationDomain;
		}

		/**
		 * @inheritDoc
		 */
		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}

		// ----------------------------
		// autowireMode
		// ----------------------------

		[Inspectable(enumeration="no,byName,byType,constructor,autodetect", defaultValue="no")]

		/**
		 * Defines the way an object will be autowired (configured). This can be the following values: no,byName,byType,constructor,autodetect
		 */
		public function get autoWireMode():String {
			return _definition.autoWireMode.toString();
		}

		/**
		 * @private
		 */
		public function set autoWireMode(value:String):void {
			_definition.autoWireMode = AutowireMode.fromName(value);
			delete _defaultedProperties[AUTO_WIRE_MODE_FIELD_NAME];
			_explicitProperties[AUTO_WIRE_MODE_FIELD_NAME] = true;
		}

		/**
		 * Placeholder for all MXML child content of the current <code>ObjectDefinition</code>
		 */
		public function get childContent():Array {
			return _childContent;
		}

		/**
		 * @private
		 */
		public function set childContent(value:Array):void {
			_childContent = value;
		}

		/**
		 * The classname of the object that the current <code>ObjectDefinition</code> describes.
		 */
		public function get className():String {
			return _definition.className;
		}

		/**
		 * @private
		 */
		public function set className(value:String):void {
			_definition.className = value;

			if (value) {
				clazz = ClassUtils.forName(value, _applicationDomain);
			}
			delete _defaultedProperties[CLASS_NAME_FIELD_NAME];
			delete _defaultedProperties[CLAZZ_FIELD_NAME];
			_explicitProperties[CLAZZ_FIELD_NAME] = true;
			_explicitProperties[CLASS_NAME_FIELD_NAME] = true;
		}

		/**
		 * The <code>Class</code> of the object that the current <code>ObjectDefinition</code> describes.
		 */
		public function get clazz():Class {
			return _definition.clazz;
		}

		/**
		 * @private
		 */
		public function set clazz(value:Class):void {
			_definition.clazz = value;
			_definition.className = (_definition.clazz != null) ? ClassUtils.getFullyQualifiedName(_definition.clazz, true) : null;
			delete _defaultedProperties[CLAZZ_FIELD_NAME];
			delete _defaultedProperties[CLASS_NAME_FIELD_NAME];
			_explicitProperties[CLAZZ_FIELD_NAME] = true;
			_explicitProperties[CLASS_NAME_FIELD_NAME] = true;
		}

		/**
		 * An array of arguments that will be passed to the constructor of the object.
		 */
		public function get constructorArguments():Array {
			return _definition.constructorArguments;
		}

		/**
		 * @private
		 */
		public function set constructorArguments(value:Array):void {
			_definition.constructorArguments = value;
		}

		/**
		 * A dictionary of property names that have not been explicitly set through MXML markup.
		 * When the current <code>ObjectDefinition</code> is configured by a <code>Template</code> or parent definition
		 * only the properties present in this dictionary will be copied from the source definition.
		 * @see org.springextensions.actionscript.context.support.mxml.Template Template
		 * @see org.springextensions.actionscript.context.support.mxml.MXMLObjectDefinition#parentObject parentObject
		 */
		public function get defaultedProperties():Dictionary {
			return _defaultedProperties;
		}

		/**
		 * The <code>IObjectDefinition</code> that is populated by the current MXML <code>ObjectDefinition</code>
		 */
		public function get definition():IObjectDefinition {
			return _definition;
		}

		[Inspectable(enumeration="none,simple,objects,all", defaultValue="none")]

		/**
		 *
		 * @return
		 */
		public function get dependencyCheck():String {
			return _definition.dependencyCheck.toString();
		}

		/**
		 * @private
		 */
		public function set dependencyCheck(value:String):void {
			_definition.dependencyCheck = DependencyCheckMode.fromName(value);
			delete _defaultedProperties[DEPENDENCY_CHECK_FIELD_NAME];
			_explicitProperties[DEPENDENCY_CHECK_FIELD_NAME] = true;
		}

		public function get dependsOn():Array {
			return _dependsOn;
		}

		/**
		 * @private
		 */
		public function set dependsOn(value:Array):void {
			_definition.dependsOn = (value && value.length > 0) ? new Vector.<String>() : null;
			_dependsOn = value;

			for each (var objDef:MXMLObjectDefinition in _dependsOn) {
				_definition.dependsOn[_definition.dependsOn.length] = objDef.id;
			}
		}

		/**
		 * The name of a method on the class defined by the <code>class</code> property that will be called when the
		 * application context is disposed. Destroy methods are used to release resources that are being kept by an object.
		 */
		public function get destroyMethod():String {
			return _definition.destroyMethod;
		}

		/**
		 * @private
		 */
		public function set destroyMethod(value:String):void {
			_definition.destroyMethod = value;
			delete _defaultedProperties[DESTROY_METHOD_FIELD_NAME];
			_explicitProperties[DESTROY_METHOD_FIELD_NAME] = true;
		}

		/**
		 * A dictionary of property names that have been explicitly set through MXML markup.
		 */
		public function get explicitProperties():Dictionary {
			return _explicitProperties;
		}

		/**
		 * The name of method responsible for the creation of the object.
		 */
		public function get factoryMethod():String {
			return _definition.factoryMethod;
		}

		/**
		 * @private
		 */
		public function set factoryMethod(value:String):void {
			_definition.factoryMethod = value;
			delete _defaultedProperties[FACTORY_METHOD_FIELD_NAME];
			_explicitProperties[FACTORY_METHOD_FIELD_NAME] = true;
		}

		/**
		 * The ObjectDefinition for the factory object responsible for the creation of the object.
		 */
		public function get factoryObject():MXMLObjectDefinition {
			return _factoryObject;
		}

		/**
		 * @private
		 */
		public function set factoryObject(value:MXMLObjectDefinition):void {
			_factoryObject = value;
			_definition.factoryObjectName = (_factoryObject != null) ? _factoryObject.id : null;
			delete _defaultedProperties[FACTORY_OBJECT_FIELD_NAME];
			delete _defaultedProperties[FACTORY_OBJECT_NAME_FIELD_NAME];
			_explicitProperties[FACTORY_OBJECT_FIELD_NAME] = true;
			_explicitProperties[FACTORY_OBJECT_NAME_FIELD_NAME] = true;
		}

		/**
		 * The name of the factory object responsible for the creation of the object.
		 */
		public function get factoryObjectName():String {
			return _definition.factoryObjectName;
		}

		/**
		 * @private
		 */
		public function set factoryObjectName(value:String):void {
			_definition.factoryObjectName = value;
			delete _defaultedProperties[FACTORY_OBJECT_FIELD_NAME];
			delete _defaultedProperties[FACTORY_OBJECT_NAME_FIELD_NAME];
			_explicitProperties[FACTORY_OBJECT_FIELD_NAME] = true;
			_explicitProperties[FACTORY_OBJECT_NAME_FIELD_NAME] = true;
		}

		/**
		 * The unique id for the current <code>ObjectDefinition</code> as defined in the MXML markup. This id will
		 * also be used to register as the name of the <code>IObjectDefinition</code> instance.
		 * @see org.springextensions.actionscript.ioc.IObjectDefinition IObjectDefinition
		 */
		public function get id():String {
			return _id;
		}

		/**
		 * @private
		 */
		public function set id(value:String):void {
			_id = value;
		}

		/**
		 * The name of a method on the class defined by the className property or clazz property that will be called immediately after the object has been configured.
		 */
		public function get initMethod():String {
			return _definition.initMethod;
		}

		/**
		 * @private
		 */
		public function set initMethod(value:String):void {
			_definition.initMethod = value;
			delete _defaultedProperties[INIT_METHOD_FIELD_NAME];
			_explicitProperties[INIT_METHOD_FIELD_NAME] = true;
		}

		// ----------------------------
		// isAutowireCandidate
		// ----------------------------

		/**
		 * True if this object can be used as a value used by the container when it autowires an object by type.
		 */
		public function get isAutoWireCandidate():Boolean {
			return _definition.isAutoWireCandidate;
		}

		/**
		 * @private
		 */
		public function set isAutoWireCandidate(value:Boolean):void {
			_definition.isAutoWireCandidate = value;
			delete _defaultedProperties[IS_AUTO_WIRE_CANDIDATE_FIELD_NAME];
			_explicitProperties[IS_AUTO_WIRE_CANDIDATE_FIELD_NAME] = true;
		}

		public function get isInitialized():Boolean {
			return _isInitialized;
		}

		/**
		 * <code>True</code> if the object does not need to be eagerly pre-instantiated by the container. I.e. the object will be created after the first call to the <code>getObject()</code> method.
		 */
		public function get isLazyInit():Boolean {
			return _definition.isLazyInit;
		}

		/**
		 * @private
		 */
		public function set isLazyInit(value:Boolean):void {
			_definition.isLazyInit = value;
			delete _defaultedProperties[IS_LAZY_INIT_FIELD_NAME];
			_explicitProperties[IS_LAZY_INIT_FIELD_NAME] = true;
		}

		/**
		 * True if only one instance of this object needs to be created by the container, i.e. every subsequent call to the getObject()  method will return the same instance.
		 */
		public function get isSingleton():Boolean {
			return (_definition.scope == ObjectDefinitionScope.SINGLETON);
		}

		/**
		 * @private
		 */
		public function set isSingleton(value:Boolean):void {
			_definition.scope = (value) ? ObjectDefinitionScope.SINGLETON : ObjectDefinitionScope.PROTOTYPE;
			delete _defaultedProperties[IS_SINGLETON_FIELD_NAME];
			delete _defaultedProperties[SCOPE_FIELD_NAME];
			_explicitProperties[IS_SINGLETON_FIELD_NAME] = true;
			_explicitProperties[SCOPE_FIELD_NAME] = true;
		}

		/**
		 * A dictionary of <code>MethodInvocation</code> objects
		 * @see org.springextensions.actionscript.context.support.mxml.MethodInvocation MethodInvocation
		 */
		public function get methodDefinitions():Dictionary {
			return _methodDefinitions;
		}


		public function get objectDefinitions():Object {
			return _objectDefinitions;
		}

		/**
		 * A dictionary of <code>Param</code> objects
		 * @see org.springextensions.actionscript.context.support.mxml.Param Param
		 */
		public function get params():Dictionary {
			return _params;
		}

		/**
		 *  If not null the specified ObjectDefinition will be used to populate the current ObjectDefinition
		 */
		public function get parentObject():MXMLObjectDefinition {
			return _parentObject;
		}

		/**
		 * @private
		 */
		public function set parentObject(value:MXMLObjectDefinition):void {
			_parentObject = value;
			_definition.parentName = value.id;
			_definition.parent = _parentObject.definition;
			delete _defaultedProperties[PARENT_OBJECT_FIELD_NAME];
			_explicitProperties[PARENT_OBJECT_FIELD_NAME] = true;
		}

		/**
		 * True if this object needs to be used as the primary autowire candidate when the container is autowiring by type. This means that if multiple objects are found of the same type, the object marked as 'primary' will become the autowire candidate.
		 */
		public function get primary():Boolean {
			return _definition.primary;
		}

		/**
		 * @private
		 */
		public function set primary(value:Boolean):void {
			_definition.primary = value;
			delete _defaultedProperties[PRIMARY_FIELD_NAME];
			_explicitProperties[PRIMARY_FIELD_NAME] = true;
		}

		[Inspectable(enumeration="prototype,singleton", defaultValue="singleton")]

		/**
		 * Defines the scope of the object, the object is either a singleton or a prototype object.
		 */
		public function get scope():String {
			return _definition.scope.toString();
		}

		/**
		 * @private
		 */
		public function set scope(value:String):void {
			Assert.notNull(value, "The scope cannot be null");
			_definition.scope = ObjectDefinitionScope.fromName(value);
			delete _defaultedProperties[IS_SINGLETON_FIELD_NAME];
			delete _defaultedProperties[SCOPE_FIELD_NAME];
			_explicitProperties[IS_SINGLETON_FIELD_NAME] = true;
			_explicitProperties[SCOPE_FIELD_NAME] = true;
		}

		public function get skipMetadata():Boolean {
			return _definition.skipMetadata;
		}

		/**
		 * @private
		 */
		public function set skipMetadata(value:Boolean):void {
			_definition.skipMetadata = value;
			delete _defaultedProperties[SKIP_METADATA_FIELD_NAME];
			_explicitProperties[SKIP_METADATA_FIELD_NAME] = true;

		}

		public function get skipPostProcessors():Boolean {
			return _definition.skipPostProcessors;
		}

		/**
		 * @private
		 */
		public function set skipPostProcessors(value:Boolean):void {
			_definition.skipPostProcessors = value;
			delete _defaultedProperties[SKIP_POST_PROCESSORS_FIELD_NAME];
			_explicitProperties[SKIP_POST_PROCESSORS_FIELD_NAME] = true;
		}

		/**
		 * Adds the specified <code>ConstructorArg</code> resolved value to the constructorArguments array.
		 * @param param The specified <code>ConstructorArg</code> instance.
		 */
		public function addConstructorArg(arg:ConstructorArg):void {
			constructorArguments[constructorArguments.length] = resolveValue(arg);
		}

		/**
		 * Adds the specified <code>MethodInvocation</code> to the methodDefinitions dictionary, then creates an <code>IObjectDefinition</code>
		 * based on the <code>MethodInvocation</code> properties, adds this to the <code>definition.methodInvocations</code> and propertyObjectDefinitions lists.
		 * @param method The specified <code>MethodInvocation</code> instance.
		 */
		public function addMethodInvocation(method:org.springextensions.actionscript.ioc.config.impl.mxml.component.MethodInvocation):void {
			var newMethod:org.springextensions.actionscript.ioc.impl.MethodInvocation = method.toMethodInvocation();
			for each (var arg:Arg in method.arguments) {
				newMethod.arguments[method.arguments.length] = resolveValue(arg);
			}
			_definition.addMethodInvocation(newMethod);
		}

		/**
		 * Adds the specified <code>Property</code> to the properties dictionary and resolves its value by invoking <code>resolveValue()</code>.
		 * @param param The specified <code>Property</code> instance.
		 */
		public function addProperty(property:Property):void {
			var propDef:PropertyDefinition = property.toPropertyDefinition();
			propDef.value = resolveValue(property);
			_definition.addPropertyDefinition(propDef);
		}

		/**
		 * After <code>FlexEvent.CREATION_COMPLETE</code> has been dispatched the <code>processChildContent()</code> method is invoked.
		 */
		public function initializeComponent():void {
			parse();
			_isInitialized = true;
		}

		/**
		 * @inheritDoc
		 */
		public function initialized(document:Object, id:String):void {
			_document = document;
			_applicationDomain ||= ApplicationDomain.currentDomain;
			_id = (StringUtils.hasText(id)) ? id : UIDUtil.createUID();
		}

		/**
		 * Parses the MXML object definition.
		 */
		public function parse():void {
			for each (var obj:* in _childContent) {
				if (obj is Property) {
					addProperty(obj);
				} else if (obj is ConstructorArg) {
					addConstructorArg(obj);
				} else if (obj is org.springextensions.actionscript.ioc.config.impl.mxml.component.MethodInvocation) {
					addMethodInvocation(obj);
				} else {
					throw new Error("Illegal child object for ObjectDefinition: " + ClassUtils.getFullyQualifiedName(ClassUtils.forInstance(obj)));
				}
			}
		}

		protected function initMXMLObjectDefinition():void {
			_objectDefinitions = {};
			_params = new Dictionary();
			_methodDefinitions = new Dictionary();
			_defaultedProperties = new Dictionary();
			_defaultedProperties[PARENT_OBJECT_FIELD_NAME] = true;
			_defaultedProperties[CLAZZ_FIELD_NAME] = true;
			_defaultedProperties[CLASS_NAME_FIELD_NAME] = true;
			_defaultedProperties[FACTORY_OBJECT_FIELD_NAME] = true;
			_defaultedProperties[FACTORY_OBJECT_NAME_FIELD_NAME] = true;
			_defaultedProperties[FACTORY_METHOD_FIELD_NAME] = true;
			_defaultedProperties[INIT_METHOD_FIELD_NAME] = true;
			_defaultedProperties[IS_SINGLETON_FIELD_NAME] = true;
			_defaultedProperties[SCOPE_FIELD_NAME] = true;
			_defaultedProperties[IS_LAZY_INIT_FIELD_NAME] = true;
			_defaultedProperties[IS_ABSTRACT_FIELD_NAME] = false;
			_defaultedProperties[IS_AUTO_WIRE_CANDIDATE_FIELD_NAME] = true;
			_defaultedProperties[AUTO_WIRE_MODE_FIELD_NAME] = true;
			_defaultedProperties[PRIMARY_FIELD_NAME] = true;
			_defaultedProperties[SKIP_POST_PROCESSORS_FIELD_NAME] = true;
			_defaultedProperties[SKIP_METADATA_FIELD_NAME] = true;
			_defaultedProperties[DEPENDENCY_CHECK_FIELD_NAME] = true;
			_defaultedProperties[DESTROY_METHOD_FIELD_NAME] = true;
			_explicitProperties = new Dictionary();
			_definition = new ObjectDefinition();
		}

		/**
		 * Returns a <code>RuntimeObjectReference</code> instance if the specified <code>Arg</code> has a ref property assigned, returns a <code>Class</code> instance
		 * if the <code>Arg</code> has a type property of "class" and a string as value, returns a <code>RuntimeObjectReference</code> if the property value is a <code>ObjectDefinition</code>
		 * and adds this instance to the propertyObjectDefinitions list, in all other cases it just returns the value of the specified <code>Arg</code>.
		 * @param arg The specified <code>Arg</code>
		 * @return The actual value of the <code>Arg</code>
		 * @see org.springextensions.actionscript.context.support.mxml.MXMLObjectDefinition ObjectDefinition
		 * @see org.springextensions.actionscript.ioc.factory.config.RuntimeObjectReference RuntimeObjectReference
		 */
		protected function resolveValue(arg:Arg):* {
			if (!arg.isInitialized) {
				arg.initializeComponent();
			}

			if (arg.ref) {
				if (arg.ref is MXMLObjectDefinition) {
					return new RuntimeObjectReference(MXMLObjectDefinition(arg.ref).id);
				} else if (arg.ref is String) {
					return new RuntimeObjectReference(String(arg.ref));
				} else {
					throw new IllegalOperationError("The ref type must either be MXMLObjectdefinition or a String that represents the ID of a definition or singleton");
				}
			} else if (arg.type) {
				if (String(arg.type).toLowerCase() == CLASS_TYPE_ATTR_NAME) {
					return ClassUtils.forName(String(arg.value), _applicationDomain);
				} else {
					return arg.value;
				}
			} else {
				var objDef:MXMLObjectDefinition = arg.value as MXMLObjectDefinition;

				if (objDef) {
					objDef.id = ANON_OBJECT_PREFIX + objDef.id;
					_objectDefinitions[objDef.id] = objDef;
					arg.value = new RuntimeObjectReference(objDef.id);
				}
				return arg.value;
			}
		}
	}
}
