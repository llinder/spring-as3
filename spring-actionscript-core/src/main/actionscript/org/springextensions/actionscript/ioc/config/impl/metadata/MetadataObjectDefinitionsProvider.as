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
package org.springextensions.actionscript.ioc.config.impl.metadata {
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.errors.IllegalOperationError;
	import flash.system.ApplicationDomain;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.bytecode.reflect.ByteCodeType;
	import org.as3commons.bytecode.reflect.ByteCodeTypeCache;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.reflect.Field;
	import org.as3commons.reflect.IMetadataContainer;
	import org.as3commons.reflect.Metadata;
	import org.as3commons.reflect.Method;
	import org.as3commons.reflect.Parameter;
	import org.as3commons.reflect.Type;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.impl.RuntimeObjectReference;
	import org.springextensions.actionscript.ioc.config.impl.metadata.util.MetadataConfigUtils;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;
	import org.springextensions.actionscript.ioc.error.UnsatisfiedDependencyError;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.DefaultObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.PropertyDefinition;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class MetadataObjectDefinitionsProvider implements IObjectDefinitionsProvider, IDisposable, IApplicationContextAware, ILoaderInfoAware {

		private static const CREATING_OBJECT_DEFINITION:String = "Creating object definition for class '{0}'.";
		private static const MULTIPLE_COMPONENT_METADATA_ERROR:String = "Only one Component metadata annotation can be used";
		private static const OBJECT_DEFINITION_ALREADY_EXISTS:String = "Object definition for class '{0}' already exists.";
		private static const PROPERTY_REGEXP:RegExp = /\$\{[^}]+\}/g;
		private static const PROPERTY_REGEXP2:RegExp = /\$\([^)]+\)/g;
		private static const SCANNING_CLASS:String = "Scanning class '{0}' for Component metadata.";
		private static const LOGGER:ILogger = getLogger(MetadataObjectDefinitionsProvider);
		private static var _numScannedComponents:uint = 0;

		/**
		 * Creates a new <code>MetadataObjectDefinitionsProvider</code> instance.
		 */
		public function MetadataObjectDefinitionsProvider() {
			super();
			_internalRegistry = new DefaultObjectDefinitionRegistry();
			_metadataConfigUtils = new MetadataConfigUtils();
			_configurationScanner = new ConfigurationClassScanner(_metadataConfigUtils, applicationContext);
		}

		private var _applicationContext:IApplicationContext;
		private var _classesBeingScanned:Vector.<Class>;
		private var _internalRegistry:IObjectDefinitionRegistry;
		private var _isDisposed:Boolean;
		private var _objectDefinitions:Object;
		private var _propertiesProvider:IPropertiesProvider;
		private var _propertyURIs:Vector.<TextFileURI>;
		private var _configurationScanner:ConfigurationClassScanner;
		private var _metadataConfigUtils:MetadataConfigUtils;
		private var _customConfigurators:Object;

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
			if (_applicationContext != null) {
				_configurationScanner.applicationDomain = _applicationContext.applicationDomain;
			}
		}


		public function get internalRegistry():IObjectDefinitionRegistry {
			return _internalRegistry;
		}

		/**
		 * @inheritDoc
		 */
		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		/**
		 * @inheritDoc
		 */
		public function get loaderInfo():LoaderInfo {
			return (_applicationContext is ILoaderInfoAware) ? ILoaderInfoAware(_applicationContext).loaderInfo : null;
		}

		/**
		 * @private
		 */
		public function set loaderInfo(value:LoaderInfo):void {
			if (_applicationContext is ILoaderInfoAware) {
				ILoaderInfoAware(_applicationContext).loaderInfo = value;
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get objectDefinitions():Object {
			return _objectDefinitions;
		}

		/**
		 * @inheritDoc
		 */
		public function get propertiesProvider():IPropertiesProvider {
			return _propertiesProvider;
		}

		/**
		 * @inheritDoc
		 */
		public function get propertyURIs():Vector.<TextFileURI> {
			return _propertyURIs;
		}

		/**
		 * @inheritDoc
		 */
		public function createDefinitions():IOperation {
			if (loaderInfo != null) {
				ByteCodeType.metaDataLookupFromLoader(loaderInfo);
			}
			var cache:ByteCodeTypeCache = ByteCodeType.getCache();
			_objectDefinitions = createObjectDefinitions(cache);
			createPropertyObjects(cache);
			return null;
		}

		/**
		 *
		 * @param cache
		 * @return
		 */
		public function createObjectDefinitions(cache:ByteCodeTypeCache):Object {
			initialize(cache);
			var classNames:Array = cache.getClassesWithMetadata(MetadataConfigUtils.CONFIGURATION_METADATA);
			_configurationScanner.scanClassNames(classNames, _internalRegistry, _customConfigurators);
			classNames = cache.getClassesWithMetadata(MetadataConfigUtils.COMPONENT_METADATA);
			scanClassNames(classNames);
			return createResult();
		}

		protected function initialize(cache:ByteCodeTypeCache):void {
			var interfaceName:String = ClassUtils.getFullyQualifiedName(ICustomConfigurationClassScanner, true);
			var classNames:Array = cache.interfaceLookup[interfaceName];
			for each (var className:String in classNames) {
				var type:Type = Type.forName(className, _applicationContext.applicationDomain);
				if (type.constructor.parameters.length == 0) {
					var scanner:ICustomConfigurationClassScanner = _applicationContext.createInstance(type.clazz);
					registerCustomConfigurationClassScanner(scanner);
				}
			}
		}

		/**
		 *
		 * @param classNames
		 */
		public function scanClassNames(classNames:Array):void {
			_classesBeingScanned = getClassesFromClassNames(classNames);
			for each (var className:String in classNames) {
				scan(className);
			}
			resolveMembers();
		}

		protected function resolveMembers():void {
			var names:Vector.<String> = _internalRegistry.objectDefinitionNames;
			for each (var name:String in names) {
				var definition:IObjectDefinition = _internalRegistry.getObjectDefinition(name);
				var type:Type = Type.forClass(definition.clazz, _applicationContext.applicationDomain);
				resolveConstructorArgs(type, definition, name);
				resolveMethods(type, definition);
				resolveProperties(type, definition, name);
			}
		}

		/**
		 *
		 * @param cache
		 */
		public function createPropertyObjects(cache:ByteCodeTypeCache):void {
			var classNames:Array = cache.getClassesWithMetadata(MetadataConfigUtils.EXTERNAL_PROPERTIES_METADATA);
			for each (var name:String in classNames) {
				extractExternalPropertyMetadata(name);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			if (!_isDisposed) {
				_isDisposed = true;
			}
		}

		/**
		 *
		 * @param className
		 */
		public function extractExternalPropertyMetadata(className:String):void {
			var type:Type = Type.forName(className, applicationContext.applicationDomain);
			var metadatas:Array = type.getMetadata(MetadataConfigUtils.EXTERNAL_PROPERTIES_METADATA);
			for each (var metadata:Metadata in metadatas) {
				createPropertyURI(metadata);
			}
		}

		/**
		 *
		 * @param className
		 */
		public function scan(className:String):void {
			var clazz:Class = ClassUtils.forName(className, applicationContext.applicationDomain);

			var type:Type = Type.forClass(clazz, applicationContext.applicationDomain);

			LOGGER.debug(SCANNING_CLASS, [className]);

			if (type.hasMetadata(MetadataConfigUtils.COMPONENT_METADATA)) {
				var metadata:Array = type.getMetadata(MetadataConfigUtils.COMPONENT_METADATA);

				if (metadata.length > 1) {
					throw new Error(MULTIPLE_COMPONENT_METADATA_ERROR);
				}

				var componentMetaData:Metadata = Metadata(metadata[0]);
				var componentId:String = getComponentIdFromMetaData(componentMetaData);
				var objectDefinitionExists:Boolean = false;

				if (componentId) {
					objectDefinitionExists = _internalRegistry.containsObjectDefinition(componentId);
				}

				if (objectDefinitionExists) {
					LOGGER.debug(OBJECT_DEFINITION_ALREADY_EXISTS, [className]);
				} else {
					LOGGER.debug(CREATING_OBJECT_DEFINITION, [className]);

					var definition:ObjectDefinition = new ObjectDefinition(className);
					definition.isInterface = ClassUtils.isInterface(clazz);
					definition.isSingleton = !ClassUtils.isSubclassOf(clazz, DisplayObject, applicationContext.applicationDomain);
					_metadataConfigUtils.resolveDefinitionProperties(componentMetaData, definition, className);

					if (componentId == null) {
						componentId = MetadataConfigUtils.SCANNED_COMPONENT_NAME_PREFIX + ++_numScannedComponents;
					}
					_internalRegistry.registerObjectDefinition(componentId, definition);
				}
			}

		}


		public function registerCustomConfigurationClassScanner(configurator:ICustomConfigurationClassScanner):void {
			for each (var metadataName:String in configurator.metadataNames) {
				var configurators:Vector.<ICustomConfigurationClassScanner> = _customConfigurators[metadataName] ||= new Vector.<ICustomConfigurator>();
				configurators[configurators.length] = configurator;
			}
		}

		/**
		 *
		 * @param method
		 * @param definition
		 */
		protected function addMethod(method:Method, definition:IObjectDefinition):void {
			var metadata:Metadata = method.getMetadata(MetadataConfigUtils.INVOKE_METADATA)[0];
			var arguments:Array = _metadataConfigUtils.resolveArguments(metadata);
			var mv:MethodInvocation = new MethodInvocation(method.name, arguments, method.namespaceURI);
			definition.addMethodInvocation(mv);
		}

		/**
		 *
		 * @param field
		 * @param definition
		 */
		protected function addProperty(field:Field, definition:IObjectDefinition):void {
			var metadata:Metadata = field.getMetadata(MetadataConfigUtils.PROPERTY_METADATA)[0];
			var propertyValue:*;
			if (metadata.hasArgumentWithKey(MetadataConfigUtils.REF_ATTR)) {
				propertyValue = new RuntimeObjectReference(metadata.getArgument(MetadataConfigUtils.REF_ATTR).value);
			} else if (metadata.hasArgumentWithKey(MetadataConfigUtils.VALUE_ATTR)) {
				propertyValue = metadata.getArgument(MetadataConfigUtils.VALUE_ATTR).value;
			}
			var propertyDef:PropertyDefinition = new PropertyDefinition(field.name, propertyValue, field.namespaceURI, field.isStatic);
			definition.addPropertyDefinition(propertyDef);
		}

		/**
		 *
		 * @param metadata
		 */
		protected function createPropertyURI(metadata:Metadata):void {
			var URI:String;
			var isRequired:Boolean = true;
			var preventCache:Boolean = true;
			if (metadata.hasArgumentWithKey(MetadataConfigUtils.LOCATION_ATTR)) {
				URI = metadata.getArgument(MetadataConfigUtils.LOCATION_ATTR).value;
			} else if (metadata.hasArgumentWithKey(MetadataConfigUtils.EMPTY)) {
				URI = metadata.getArgument(MetadataConfigUtils.EMPTY).value;
			} else {
				throw new IllegalOperationError("ExternalProperty metadata does not have a valid 'location' argument defined");
			}
			if (metadata.hasArgumentWithKey(MetadataConfigUtils.REQUIRED_ATTR)) {
				isRequired = (metadata.getArgument(MetadataConfigUtils.REQUIRED_ATTR).value.toLowerCase() == MetadataConfigUtils.TRUE_VALUE);
			}
			if (metadata.hasArgumentWithKey(MetadataConfigUtils.PREVENTCACHE_ATTR)) {
				preventCache = (metadata.getArgument(MetadataConfigUtils.PREVENTCACHE_ATTR).value.toLowerCase() == MetadataConfigUtils.TRUE_VALUE);
			}
			var propertyURI:TextFileURI = new TextFileURI(URI, isRequired, preventCache);
			_propertyURIs ||= new Vector.<TextFileURI>();
			_propertyURIs[_propertyURIs.length] = propertyURI;
		}

		/**
		 *
		 * @return
		 */
		protected function createResult():Object {
			var result:Object;
			var names:Vector.<String> = _internalRegistry.objectDefinitionNames.concat();
			for each (var name:String in names) {
				result ||= {};
				var definition:IObjectDefinition = _internalRegistry.removeObjectDefinition(name);
				definition.registryId = "";
				result[name] = definition;
			}
			return result;
		}


		/**
		 *
		 * @param classNames
		 * @return
		 */
		protected function getClassesFromClassNames(classNames:Array):Vector.<Class> {
			var result:Vector.<Class> = new Vector.<Class>();
			var appDomain:ApplicationDomain = (applicationContext != null) ? applicationContext.applicationDomain : null;

			for each (var className:String in classNames) {
				result[result.length] = ClassUtils.forName(className, appDomain);
			}

			return result;
		}

		/**
		 *
		 * @param metadata
		 * @return
		 */
		protected function getComponentIdFromMetaData(metadata:Metadata):String {
			var result:String;

			if (metadata.hasArgumentWithKey(MetadataConfigUtils.ID_ATTR)) {
				result = metadata.getArgument(MetadataConfigUtils.ID_ATTR).value;
			} else if (metadata.hasArgumentWithKey(MetadataConfigUtils.EMPTY)) {
				result = metadata.getArgument(MetadataConfigUtils.EMPTY).value;
			}

			return result;
		}

		/**
		 *
		 * @param interfaze
		 * @param classes
		 * @return
		 */
		protected function getInterfaceImplementations(interfaze:Class, classes:Vector.<Class>):Vector.<Class> {
			var result:Vector.<Class>;

			for each (var clazz:Class in classes) {
				result ||= new Vector.<Class>();
				if (ClassUtils.isImplementationOf(clazz, interfaze)) {
					result[result.length] = clazz;
				}
			}

			return result;
		}

		/**
		 *
		 * @param clazz
		 * @param objectDefinitionId
		 * @param propertyName
		 * @return
		 */
		protected function getObjectDefinitionsThatMatchClass(clazz:Class, objectDefinitionId:String, propertyName:String=""):Vector.<String> {
			var result:Vector.<String> = _internalRegistry.getObjectNamesForType(clazz);

			// no definition for class, perhaps the class has not been scanned yet
			if (result == null) {
				// if this clazz is an interface, look up an implementation in the classes that are currently being scanned
				if (ClassUtils.isInterface(clazz)) {
					var implementationClasses:Vector.<Class> = getInterfaceImplementations(clazz, _classesBeingScanned);

					if (implementationClasses == null) {
						throw new UnsatisfiedDependencyError(objectDefinitionId, propertyName, "No implementation of interface '" + clazz + "' found.");
					} else if (implementationClasses.length == 1) {
						scan(ClassUtils.getFullyQualifiedName(implementationClasses[0], true));
					} else {
						throw new UnsatisfiedDependencyError(objectDefinitionId, propertyName, "More than one implementation of interface '" + clazz + "' found.");
					}
				} else {
					scan(ClassUtils.getFullyQualifiedName(clazz, true));
				}
			}

			result = _internalRegistry.getObjectNamesForType(clazz);

			return result;
		}

		/**
		 *
		 * @param type
		 * @param definition
		 * @param objectDefinitionId
		 *
		 */
		protected function resolveConstructorArgs(type:Type, definition:IObjectDefinition, objectDefinitionId:String):void {
			if (type.hasMetadata(MetadataConfigUtils.CONSTRUCTOR_METADATA)) {
				var constructorArguments:Array = _metadataConfigUtils.resolveArguments(type.getMetadata(MetadataConfigUtils.CONSTRUCTOR_METADATA)[0]);
				if (constructorArguments) {
					definition.constructorArguments = constructorArguments;
				}
			} else {
				resolveConstructorArgsViaReflection(type, definition, objectDefinitionId);
			}
		}

		/**
		 *
		 * @param type
		 * @param definition
		 * @param objectDefinitionId
		 *
		 */
		protected function resolveConstructorArgsViaReflection(type:Type, definition:IObjectDefinition, objectDefinitionId:String):void {
			if (type.constructor && type.constructor.parameters) {
				var numConstructorArgs:uint = type.constructor.parameters.length;

				for (var i:int = 0; i < numConstructorArgs; ++i) {
					var constructorArg:Parameter = type.constructor.parameters[i];
					var constructorArgClass:Class = constructorArg.type.clazz;
					var objectDefinitionsThatMatchConstructorArgClass:Vector.<String> = getObjectDefinitionsThatMatchClass(constructorArgClass, objectDefinitionId);

					if (objectDefinitionsThatMatchConstructorArgClass == null) {
						throw new UnsatisfiedDependencyError(objectDefinitionId, "constructor arg#" + i.toString());
					} else if (objectDefinitionsThatMatchConstructorArgClass.length == 1) {
						definition.constructorArguments ||= [];

						var constructorArgDefinitionId:String = objectDefinitionsThatMatchConstructorArgClass[0];
						definition.constructorArguments.push(new RuntimeObjectReference(constructorArgDefinitionId));
					}

				}
			}
		}

		/**
		 *
		 * @param type
		 * @param definition
		 */
		protected function resolveMethods(type:Type, definition:IObjectDefinition):void {
			var containers:Array = type.getMetadataContainers(MetadataConfigUtils.INVOKE_METADATA);
			for each (var container:IMetadataContainer in containers) {
				if (container is Method) {
					addMethod(Method(container), definition);
				}
			}
		}

		/**
		 *
		 * @param type
		 * @param definition
		 * @param objectDefinitionId
		 */
		protected function resolveProperties(type:Type, definition:IObjectDefinition, objectDefinitionId:String):void {
			resolvePropertiesFromMetadata(type, definition);
		}

		/**
		 *
		 * @param type
		 * @param definition
		 */
		protected function resolvePropertiesFromMetadata(type:Type, definition:IObjectDefinition):void {
			var containers:Array = type.getMetadataContainers(MetadataConfigUtils.PROPERTY_METADATA);
			for each (var container:IMetadataContainer in containers) {
				if (container is Field) {
					addProperty(Field(container), definition);
				}
			}
		}
	}
}
