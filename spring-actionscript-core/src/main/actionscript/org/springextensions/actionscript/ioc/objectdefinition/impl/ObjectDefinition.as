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
	import org.as3commons.lang.Assert;
	import org.as3commons.lang.IEquals;
	import org.as3commons.lang.builder.EqualsBuilder;
	import org.springextensions.actionscript.ioc.autowire.AutowireMode;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.ObjectDefinitionScope;

	/**
	 * Describes an object that can be created by an <code>ObjectFactory</code>.
	 * @author Christophe Herreman, Damir Murat
	 * @docref container-documentation.html#the_objects
	 */
	public class ObjectDefinition implements IObjectDefinition, IEquals {

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
		private var _dependencyCheck:DependencyCheckMode;
		private var _dependsOn:Vector.<String>;
		private var _destroyMethod:String;
		private var _factoryMethod:String;
		private var _factoryObjectName:String;
		private var _initMethod:String;
		private var _interfaceDefinitions:Vector.<IObjectDefinition>;
		private var _isAutoWireCandidate:Boolean;
		private var _isInterface:Boolean;
		private var _isLazyInit:Boolean;
		private var _methodInvocations:Vector.<MethodInvocation>;
		private var _parent:IObjectDefinition;
		private var _primary:Boolean;
		private var _properties:Object;
		private var _scope:ObjectDefinitionScope;
		private var _skipMetadata:Boolean = false;
		private var _skipPostProcessors:Boolean = false;

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

		public function get clazz():Class {
			return _clazz;
		}

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

		public function get interfaceDefinitions():Vector.<IObjectDefinition> {
			return _interfaceDefinitions;
		}

		public function set interfaceDefinitions(value:Vector.<IObjectDefinition>):void {
			_interfaceDefinitions = value;
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

		public function get isInterface():Boolean {
			return _isInterface;
		}

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

		public function get parent():IObjectDefinition {
			return _parent;
		}

		public function set parent(value:IObjectDefinition):void {
			_parent = value;
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
		public function get properties():Object {
			return _properties;
		}

		/**
		 * @private
		 */
		public function set properties(value:Object):void {
			_properties = value;
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
				append(isInterface, that.isInterface). //
				append(interfaceDefinitions, that.interfaceDefinitions). //
				equals;
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
	}
}
