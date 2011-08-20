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
package org.springextensions.actionscript.ioc.objectdefinition.impl {
	import flash.utils.Dictionary;

	import org.as3commons.lang.Assert;
	import org.as3commons.lang.IEquals;
	import org.as3commons.lang.builder.EqualsBuilder;
	import org.springextensions.actionscript.ioc.autowire.AutowireMode;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.ObjectDefinitionAccess;
	import org.springextensions.actionscript.ioc.objectdefinition.ObjectDefinitionScope;

	/**
	 * Describes an object that can be created by an <code>ObjectFactory</code>.
	 * @author Christophe Herreman, Damir Murat
	 * @docref container-documentation.html#the_objects
	 */
	public class ObjectDefinition implements IObjectDefinition, IEquals {

		private static const COLON:String = ':';

		/**
		 * Creates a new <code>ObjectDefinition</code> instance.
		 * @param className The fully qualified class name for the object that this definition describes
		 */
		public function ObjectDefinition(clazzName:String=null) {
			super();
			initObjectDefinition(clazzName);
		}

		private var _autoWireMode:AutowireMode;
		private var _className:String;
		private var _clazz:Class;
		private var _constructorArguments:Array;
		private var _customConfiguration:*;
		private var _dependencyCheck:DependencyCheckMode;
		private var _dependsOn:Vector.<String>;
		private var _destroyMethod:String;
		private var _factoryMethod:String;
		private var _factoryObjectName:String;
		private var _initMethod:String;
		private var _isAbstract:Boolean;
		private var _isAutoWireCandidate:Boolean;
		private var _isInterface:Boolean;
		private var _isLazyInit:Boolean;
		private var _methodInvocations:Vector.<MethodInvocation>;
		private var _methodNameLookup:Object;
		private var _parent:IObjectDefinition;
		private var _parentName:String;
		private var _primary:Boolean;
		private var _properties:Vector.<PropertyDefinition>;
		private var _propertyNameLookup:Object;
		private var _registryId:String;
		private var _scope:ObjectDefinitionScope;
		private var _skipMetadata:Boolean = false;
		private var _skipPostProcessors:Boolean = false;
		private var _access:ObjectDefinitionAccess;

		/**
		 * @default AutowireMode.NO
		 * @inheritDoc
		 */
		public function get autoWireMode():AutowireMode {
			return _autoWireMode;
		}

		/**
		 * @private
		 */
		public function set autoWireMode(value:AutowireMode):void {
			_autoWireMode = (value) ? value : AutowireMode.NO;
		}

		/**
		 * @inheritDoc
		 */
		public function get className():String {
			return _className;
		}

		/**
		 * @private
		 */
		public function set className(value:String):void {
			_className = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get clazz():Class {
			return _clazz;
		}

		/**
		 * @private
		 */
		public function set clazz(value:Class):void {
			_clazz = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get constructorArguments():Array {
			return _constructorArguments;
		}

		/**
		 * @private
		 */
		public function set constructorArguments(value:Array):void {
			_constructorArguments = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get customConfiguration():* {
			return _customConfiguration;
		}

		/**
		 * @private
		 */
		public function set customConfiguration(value:*):void {
			_customConfiguration = value;
		}

		/**
		 * @default <code>ObjectDefinitionDependencyCheck.NONE</code>
		 * @inheritDoc
		 */
		public function get dependencyCheck():DependencyCheckMode {
			return _dependencyCheck;
		}

		/**
		 * @inheritDoc
		 */
		public function set dependencyCheck(value:DependencyCheckMode):void {
			_dependencyCheck = (value) ? value : DependencyCheckMode.NONE;
		}

		/**
		 * @inheritDoc
		 */
		public function get dependsOn():Vector.<String> {
			return _dependsOn;
		}

		/**
		 * @private
		 */
		public function set dependsOn(value:Vector.<String>):void {
			_dependsOn = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get destroyMethod():String {
			return _destroyMethod;
		}

		/**
		 * @private
		 */
		public function set destroyMethod(value:String):void {
			_destroyMethod = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get factoryMethod():String {
			return _factoryMethod;
		}

		/**
		 * @private
		 */
		public function set factoryMethod(value:String):void {
			_factoryMethod = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get factoryObjectName():String {
			return _factoryObjectName;
		}

		/**
		 * @private
		 */
		public function set factoryObjectName(value:String):void {
			_factoryObjectName = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get initMethod():String {
			return _initMethod;
		}

		/**
		 * @private
		 */
		public function set initMethod(value:String):void {
			_initMethod = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get isAbstract():Boolean {
			return _isAbstract;
		}

		/**
		 * @private
		 */
		public function set isAbstract(value:Boolean):void {
			_isAbstract = value;
		}

		/**
		 * @default true
		 * @inheritDoc
		 */
		public function get isAutoWireCandidate():Boolean {
			return _isAutoWireCandidate;
		}

		/**
		 * @private
		 */
		public function set isAutoWireCandidate(value:Boolean):void {
			_isAutoWireCandidate = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get isInterface():Boolean {
			return _isInterface;
		}

		/**
		 * @private
		 */
		public function set isInterface(value:Boolean):void {
			_isInterface = value;
		}

		/**
		 * @default false
		 * @inheritDoc
		 */
		public function get isLazyInit():Boolean {
			return _isLazyInit;
		}

		/**
		 * @private
		 */
		public function set isLazyInit(value:Boolean):void {
			_isLazyInit = value;
		}

		/**
		 * @default true
		 * @inheritDoc
		 */
		public function get isSingleton():Boolean {
			return (scope == ObjectDefinitionScope.SINGLETON);
		}

		/**
		 * @private
		 */
		public function set isSingleton(value:Boolean):void {
			scope = (value) ? ObjectDefinitionScope.SINGLETON : ObjectDefinitionScope.PROTOTYPE;
		}

		/**
		 * @inheritDoc
		 */
		public function get methodInvocations():Vector.<MethodInvocation> {
			return _methodInvocations;
		}

		/**
		 * @private
		 */
		public function set methodInvocations(value:Vector.<MethodInvocation>):void {
			_methodInvocations = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get parent():IObjectDefinition {
			return _parent;
		}

		/**
		 * @private
		 */
		public function set parent(value:IObjectDefinition):void {
			_parent = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get parentName():String {
			return _parentName;
		}

		/**
		 * @private
		 */
		public function set parentName(value:String):void {
			_parentName = value;
		}

		/**
		 * @default false
		 * @inheritDoc
		 */
		public function get primary():Boolean {
			return _primary;
		}

		/**
		 * @private
		 */
		public function set primary(value:Boolean):void {
			_primary = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get properties():Vector.<PropertyDefinition> {
			return _properties;
		}

		/**
		 * @inheritDoc
		 */
		public function get registryId():String {
			return _registryId;
		}

		/**
		 * @private
		 */
		public function set registryId(value:String):void {
			_registryId = value;
		}

		/**
		 * @default ObjectDefinitionScope.SINGLETON
		 * @inheritDoc
		 */
		public function get scope():ObjectDefinitionScope {
			return _scope;
		}

		/**
		 * @private
		 */
		public function set scope(value:ObjectDefinitionScope):void {
			_scope = value ||= ObjectDefinitionScope.SINGLETON;
		}

		/**
		 * @default false
		 * @inheritDoc
		 */
		public function get skipMetadata():Boolean {
			return _skipMetadata;
		}

		/**
		 * @inheritDoc
		 */
		public function set skipMetadata(value:Boolean):void {
			_skipMetadata = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get skipPostProcessors():Boolean {
			return _skipPostProcessors;
		}

		/**
		 * @default false
		 * @inheritDoc
		 */
		public function set skipPostProcessors(value:Boolean):void {
			_skipPostProcessors = value;
		}

		/**
		 * @inheritDoc
		 */
		public function addMethodInvocation(methodInvocation:MethodInvocation):void {
			_methodNameLookup ||= {};
			_methodInvocations ||= new Vector.<MethodInvocation>();
			_methodInvocations[_methodInvocations.length] = methodInvocation;
			var name:String = (methodInvocation.namespaceURI != null) ? methodInvocation.namespaceURI + COLON + methodInvocation.methodName : methodInvocation.methodName;
			_methodNameLookup[name] = methodInvocation;
		}

		/**
		 * @inheritDoc
		 */
		public function addPropertyDefinition(propertyDefinition:PropertyDefinition):void {
			_propertyNameLookup ||= {};
			_properties ||= new Vector.<PropertyDefinition>();
			_properties[_properties.length] = propertyDefinition;
			var name:String = (propertyDefinition.namespaceURI != null) ? propertyDefinition.namespaceURI + COLON + propertyDefinition.name : propertyDefinition.name;
			_propertyNameLookup[name] = propertyDefinition;
		}

		/**
		 *
		 */
		public function equals(object:Object):Boolean {
			if (!(object is IObjectDefinition)) {
				return false;
			}

			if (object === this) {
				return true;
			}

			var that:IObjectDefinition = IObjectDefinition(object);

			return new EqualsBuilder().append(autoWireMode, that.autoWireMode). //
				append(className, that.className). //
				append(constructorArguments, that.constructorArguments). //
				append(dependsOn, that.dependsOn). //
				append(factoryMethod, that.factoryMethod). //
				append(factoryObjectName, that.factoryObjectName). //
				append(initMethod, that.initMethod). //
				append(isAutoWireCandidate, that.isAutoWireCandidate). //
				append(isLazyInit, that.isLazyInit). //
				append(isSingleton, that.isSingleton). //
				append(methodInvocations, that.methodInvocations). //
				append(skipPostProcessors, that.skipPostProcessors). //
				append(skipMetadata, that.skipMetadata). //
				append(primary, that.primary). //
				append(properties, that.properties). //
				append(scope, that.scope). //
				append(dependencyCheck, that.dependencyCheck). //
				append(parent, that.parent). //
				append(parentName, that.parentName). //
				append(isInterface, that.isInterface). //
				append(customConfiguration, that.customConfiguration). //
				equals;
		}

		/**
		 * @inheritDoc
		 */
		public function getMethodInvocationByName(name:String, namespace:String=null):MethodInvocation {
			_methodNameLookup ||= {};
			var methodName:String = (namespace != null) ? namespace + COLON + name : name;
			return _methodNameLookup[methodName] as MethodInvocation;
		}

		/**
		 * @inheritDoc
		 */
		public function getPropertyDefinitionByName(name:String, namespace:String=null):PropertyDefinition {
			_propertyNameLookup ||= {};
			var propertyName:String = (namespace != null) ? namespace + COLON + name : name;
			return _propertyNameLookup[propertyName] as PropertyDefinition;
		}

		/**
		 *
		 * @param className
		 */
		protected function initObjectDefinition(clazzName:String):void {
			className = clazzName;
			scope = ObjectDefinitionScope.SINGLETON;
			isLazyInit = false;
			autoWireMode = AutowireMode.NO;
			isAutoWireCandidate = true;
			primary = false;
			dependencyCheck = DependencyCheckMode.NONE;
		}

		/**
		 * @inheritDoc
		 */
		public function get access():ObjectDefinitionAccess {
			return _access;
		}

		/**
		 * @private
		 */
		public function set access(value:ObjectDefinitionAccess):void {
			_access = value;
		}
	}
}
