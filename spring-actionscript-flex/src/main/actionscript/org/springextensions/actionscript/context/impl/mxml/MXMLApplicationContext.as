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
package org.springextensions.actionscript.context.impl.mxml {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;

	import mx.binding.utils.BindingUtils;
	import mx.core.IMXMLObject;
	import mx.events.FlexEvent;

	import org.as3commons.stageprocessing.IStageObjectProcessorRegistry;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.config.IConfigurationPackage;
	import org.springextensions.actionscript.context.impl.DefaultApplicationContext;
	import org.springextensions.actionscript.ioc.IDependencyInjector;
	import org.springextensions.actionscript.ioc.IObjectDestroyer;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.ITextFilesLoader;
	import org.springextensions.actionscript.ioc.config.impl.mxml.MXMLObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesParser;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.factory.IInstanceCache;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.IObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.IObjectPostProcessor;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.util.ContextUtils;

	[Event(name="complete", type="flash.events.Event")]
	/**
	 *
	 * @author Roland Zwaga
	 */
	public class MXMLApplicationContext extends EventDispatcher implements IMXMLObject, IApplicationContext {

		public static const AUTOLOAD_CHANGED_EVENT:String = "autoLoadChanged";
		public static const CONFIGURATIONPACKAGE_CHANGED_EVENT:String = "configurationPackageChanged";
		public static const CONFIGURATIONS_CHANGED_EVENT:String = "configurationsChanged";
		public static const DOCUMENT_CHANGED_EVENT:String = "documentChanged";
		public static const ID_CHANGED_EVENT:String = "idChanged";

		{
			BindingUtils;
		}

		public function MXMLApplicationContext() {
			super();
		}

		private var _applicationContext:IApplicationContext;
		private var _autoLoad:Boolean = false;
		private var _configurationPackage:IConfigurationPackage;
		private var _configurations:Array;
		private var _document:Object;
		private var _id:String;
		private var _contextInitialized:Boolean;

		public function get contextInitialized():Boolean {
			return _contextInitialized;
		}

		/**
		 * @inheritDoc
		 */
		public function get applicationContext():IApplicationContext {
			return _applicationContext;
		}

		/**
		 * @private
		 */
		public function set applicationContext(value:IApplicationContext):void {
			_applicationContext = value;
		}

		public function get applicationDomain():ApplicationDomain {
			return _applicationContext.applicationDomain;
		}

		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationContext.applicationDomain = value;
		}

		[Bindable(event="autoLoadChanged")]
		/**
		 * @inheritDoc
		 */
		public function get autoLoad():Boolean {
			return _autoLoad;
		}

		/**
		 * @private
		 */
		public function set autoLoad(value:Boolean):void {
			if (_autoLoad != value) {
				_autoLoad = value;
				dispatchEvent(new Event(AUTOLOAD_CHANGED_EVENT));
			}
		}

		public function get cache():IInstanceCache {
			return _applicationContext.cache;
		}

		public function get childContexts():Vector.<IApplicationContext> {
			return _applicationContext.childContexts;
		}

		[Bindable(event="configurationPackageChanged")]
		/**
		 * @inheritDoc
		 */
		public function get configurationPackage():IConfigurationPackage {
			return _configurationPackage;
		}

		/**
		 * @private
		 */
		public function set configurationPackage(value:IConfigurationPackage):void {
			if (_configurationPackage !== value) {
				_configurationPackage = value;
				dispatchEvent(new Event(CONFIGURATIONPACKAGE_CHANGED_EVENT));
			}
		}

		[Bindable(event="configurationsChanged")]
		/**
		 *
		 */
		public function get configurations():Array {
			return _configurations;
		}

		/**
		 * @private
		 */
		public function set configurations(value:Array):void {
			if (_configurations != value) {
				_configurations = value;
				dispatchEvent(new Event(CONFIGURATIONS_CHANGED_EVENT));
			}
		}

		public function get definitionProviders():Vector.<IObjectDefinitionsProvider> {
			return _applicationContext.definitionProviders;
		}

		public function get dependencyInjector():IDependencyInjector {
			return _applicationContext.dependencyInjector;
		}

		public function set dependencyInjector(value:IDependencyInjector):void {
			_applicationContext.dependencyInjector = value;
		}

		[Bindable(event="documentChanged")]
		/**
		 * @inheritDoc
		 */
		public function get document():Object {
			return _document;
		}

		/**
		 * @private
		 */
		public function set document(value:Object):void {
			if (_document != value) {
				_document = value;
				dispatchEvent(new Event(DOCUMENT_CHANGED_EVENT));
			}
		}

		[Bindable(event="idChanged")]
		/**
		 * @inheritDoc
		 */
		public function get id():String {
			return _id;
		}

		/**
		 * @private
		 */
		public function set id(value:String):void {
			if (_id != value) {
				_id = value;
				dispatchEvent(new Event(ID_CHANGED_EVENT));
			}
		}

		public function get isReady():Boolean {
			return _applicationContext.isReady;
		}

		public function set isReady(value:Boolean):void {
			_applicationContext.isReady = value;
		}

		public function get objectDefinitionRegistry():IObjectDefinitionRegistry {
			return _applicationContext.objectDefinitionRegistry;
		}

		public function set objectDefinitionRegistry(value:IObjectDefinitionRegistry):void {
			_applicationContext.objectDefinitionRegistry = value;
		}

		public function get objectFactoryPostProcessors():Vector.<IObjectFactoryPostProcessor> {
			return _applicationContext.objectFactoryPostProcessors;
		}

		public function get objectPostProcessors():Vector.<IObjectPostProcessor> {
			return _applicationContext.objectPostProcessors;
		}

		public function get parent():IObjectFactory {
			return _applicationContext.parent;
		}

		public function set parent(value:IObjectFactory):void {
			_applicationContext.parent = value;
		}

		public function get propertiesParser():IPropertiesParser {
			return _applicationContext.propertiesParser;
		}

		public function set propertiesParser(value:IPropertiesParser):void {
			_applicationContext.propertiesParser = value;
		}

		public function get propertiesProvider():IPropertiesProvider {
			return _applicationContext.propertiesProvider;
		}

		public function set propertiesProvider(value:IPropertiesProvider):void {
			_applicationContext.propertiesProvider = value;
		}

		public function get referenceResolvers():Vector.<IReferenceResolver> {
			return _applicationContext.referenceResolvers;
		}

		public function get rootView():DisplayObject {
			return _applicationContext.rootView;
		}

		public function get stageProcessorRegistry():IStageObjectProcessorRegistry {
			return _applicationContext.stageProcessorRegistry;
		}

		public function set stageProcessorRegistry(value:IStageObjectProcessorRegistry):void {
			_applicationContext.stageProcessorRegistry = value;
		}

		public function get textFilesLoader():ITextFilesLoader {
			return _applicationContext.textFilesLoader;
		}

		public function set textFilesLoader(value:ITextFilesLoader):void {
			_applicationContext.textFilesLoader = value;
		}

		public function addChildContext(childContext:IApplicationContext, shareDefinitions:Boolean=true, shareSingletons:Boolean=true, shareEventBus:Boolean=true):IApplicationContext {
			return _applicationContext.addChildContext(childContext, shareDefinitions, shareSingletons, shareEventBus);
		}

		public function addDefinitionProvider(provider:IObjectDefinitionsProvider):IApplicationContext {
			return _applicationContext.addDefinitionProvider(provider);
		}

		public function addObjectFactoryPostProcessor(objectFactoryPostProcessor:IObjectFactoryPostProcessor):IApplicationContext {
			return _applicationContext.addObjectFactoryPostProcessor(objectFactoryPostProcessor);
		}

		public function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):IObjectFactory {
			return _applicationContext.addObjectPostProcessor(objectPostProcessor);
		}

		public function addReferenceResolver(referenceResolver:IReferenceResolver):IObjectFactory {
			return _applicationContext.addReferenceResolver(referenceResolver);
		}

		public function canCreate(objectName:String):Boolean {
			return _applicationContext.canCreate(objectName);
		}

		public function configure(configurationPackage:IConfigurationPackage):IApplicationContext {
			return _applicationContext.configure(configurationPackage);
		}

		public function createInstance(clazz:Class, constructorArguments:Array=null):* {
			return _applicationContext.createInstance(clazz, constructorArguments);
		}

		public function getObject(name:String, constructorArguments:Array=null):* {
			return _applicationContext.getObject(name, constructorArguments);
		}

		public function getObjectDefinition(objectName:String):IObjectDefinition {
			return _applicationContext.getObjectDefinition(objectName);
		}

		/**
		 *
		 */
		public function initializeContext():void {
			if (!_contextInitialized) {
				if (_applicationContext == null) {
					_applicationContext = new DefaultApplicationContext(null, (_document as DisplayObject));
				}
				_applicationContext.addDefinitionProvider(new MXMLObjectDefinitionsProvider());
				if (_configurationPackage != null) {
					_applicationContext.configure(_configurationPackage);
				}
				ContextUtils.disposeInstance(_configurationPackage);
				_configurationPackage = null;
				_contextInitialized = true;
				if (autoLoad) {
					doLoad();
				}
			}
		}

		/**
		 *
		 * @param document
		 * @param id
		 */
		public function initialized(document:Object, id:String):void {
			_document = document;
			_id = id;
			if (_document is IEventDispatcher) {
				IEventDispatcher(_document).addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
			}
		}

		/**
		 *
		 */
		public function load():void {
			if (_contextInitialized == false) {
				initializeContext();
			}
			doLoad();
		}

		public function resolveReference(reference:*):* {
			return _applicationContext.resolveReference(reference);
		}

		public function resolveReferences(references:Array):Array {
			return _applicationContext.resolveReferences(references);
		}

		/**
		 *
		 */
		protected function doLoad():void {
			for each (var cls:Class in _configurations) {
				(_applicationContext.definitionProviders[0] as MXMLObjectDefinitionsProvider).addConfiguration(cls);
			}
			_applicationContext.addEventListener(Event.COMPLETE, handleApplicationContextComplete);
			_applicationContext.load();
		}

		/**
		 *
		 * @param event
		 */
		protected function handleApplicationContextComplete(event:Event):void {
			_applicationContext.removeEventListener(Event.COMPLETE, handleApplicationContextComplete);
			dispatchEvent(event);
		}

		/**
		 *
		 * @param event
		 */
		protected function onComplete(event:FlexEvent):void {
			IEventDispatcher(_document).removeEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
			initializeContext();
		}

		public function destroyObject(instance:Object):void {
			_applicationContext.destroyObject(instance);
		}

		public function get objectDestroyer():IObjectDestroyer {
			return _applicationContext.objectDestroyer;
		}

		public function set objectDestroyer(value:IObjectDestroyer):void {
			_applicationContext.objectDestroyer = value;
		}
	}
}
