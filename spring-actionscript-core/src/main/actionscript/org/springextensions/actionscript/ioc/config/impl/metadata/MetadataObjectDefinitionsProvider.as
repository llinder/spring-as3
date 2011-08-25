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
	import flash.system.ApplicationDomain;

	import org.as3commons.async.operation.IOperation;
	import org.as3commons.bytecode.reflect.ByteCodeType;
	import org.as3commons.bytecode.reflect.ByteCodeTypeCache;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.reflect.IMetadataContainer;
	import org.as3commons.reflect.Metadata;
	import org.as3commons.reflect.MetadataArgument;
	import org.as3commons.reflect.Method;
	import org.as3commons.reflect.Parameter;
	import org.as3commons.reflect.Type;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.ioc.autowire.AutowireMode;
	import org.springextensions.actionscript.ioc.config.IObjectDefinitionsProvider;
	import org.springextensions.actionscript.ioc.config.impl.RuntimeObjectReference;
	import org.springextensions.actionscript.ioc.config.property.IPropertiesProvider;
	import org.springextensions.actionscript.ioc.config.property.TextFileURI;
	import org.springextensions.actionscript.ioc.error.UnsatisfiedDependencyError;
	import org.springextensions.actionscript.ioc.impl.MethodInvocation;
	import org.springextensions.actionscript.ioc.objectdefinition.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.ObjectDefinitionScope;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.DefaultObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public class MetadataObjectDefinitionsProvider implements IObjectDefinitionsProvider, IDisposable, IApplicationContextAware, ILoaderInfoAware {
		/** The "args" attribute. */
		public static const ARGS_ATTR:String = "args";

		/** The "autowire" attribute. */
		public static const AUTOWIRE_ATTR:String = "autowire";

		/** The "autowireCandidate" attribute. */
		public static const AUTOWIRE_CANDIDATE_ATTR:String = "autowireCandidate";

		/** The Component metadata. */
		public static const COMPONENT_METADATA:String = "Component";

		/** The Constructor metadata. */
		public static const CONSTRUCTOR_METADATA:String = "Constructor";

		/** The "dependencyCheck" attribute. */
		public static const DEPENDENCY_CHECK_ATTR:String = "dependencyCheck";

		/** The "dependsOn" attribute. */
		public static const DEPENDS_ON_ATTR:String = "dependsOn";

		/** The "destroyMethod" attribute. */
		public static const DESTROY_METHOD_ATTR:String = "destroyMethod";

		/** The "factoryMethod" attribute. */
		public static const FACTORY_METHOD_ATTR:String = "factoryMethod";

		/** The "factoryObject" attribute. */
		public static const FACTORY_OBJECT_NAME_ATTR:String = "factoryObjectName";

		/** The "id" attribute. */
		public static const ID_ATTR:String = "id";

		/** The "initMethod" attribute. */
		public static const INIT_METHOD_ATTR:String = "initMethod";

		/** The Invoke metadata. */
		public static const INVOKE_METADATA:String = "Invoke";

		/** The "lazyInit" attribute. */
		public static const LAZY_INIT_ATTR:String = "lazyInit";

		/** The "primary" attribute. */
		public static const PRIMARY_ATTR:String = "primary";

		/** The SetProperty metadata. */
		public static const PROPERTY_METADATA:String = "Property";

		/** The "ref" attribute. */
		public static const REF_ATTR:String = "ref";

		/** The prefix used when generating object definition names. */
		public static const SCANNED_COMPONENT_NAME_PREFIX:String = "scannedComponent#";

		/** The "scope" attribute. */
		public static const SCOPE_ATTR:String = "scope";

		/** The "skipMetaData" attribute. */
		public static const SKIP_METADATA_ATTR:String = "skipMetaData";

		/** The "skipPostProcessors" attribute. */
		public static const SKIP_POSTPROCESSORS_ATTR:String = "skipPostProcessors";

		/** The "value" attribute. */
		public static const VALUE_ATTR:String = "value";
		private static const COMMA:String = ',';
		private static const CREATING_OBJECT_DEFINITION:String = "Creating object definition for class '{0}'.";
		private static const EQUALS:String = '=';
		private static const IS_ABSTRACT_ATTR:String = "isAbstract";
		private static const LOGGER:ILogger = getLogger(MetadataObjectDefinitionsProvider);
		private static const MULTIPLE_COMPONENT_METADATA_ERROR:String = "Only one Component metadata annotation can be used";
		private static const OBJECT_DEFINITION_ALREADY_EXISTS:String = "Object definition for class '{0}' already exists.";
		private static const PARENT_NAME_ATTR:String = "parentName";
		/** Regular expression to resolve property placeholder with the pattern ${...} */
		private static const PROPERTY_REGEXP:RegExp = /\$\{[^}]+\}/g;
		/** Regular expression to resolve property placeholder with the pattern $(...) */
		private static const PROPERTY_REGEXP2:RegExp = /\$\([^)]+\)/g;
		private static const SCANNING_CLASS:String = "Scanning class '{0}' for Component metadata.";
		private static const SKIPPING_INTERFACE:String = "Skipping component scan on interface '{0}'.";
		private static const TRUE_VALUE:String = "true";
		private static const UNKNOWN_METADATA_ARGUMENT_ERROR:String = "Unknown metadata argument '{0}' encountered on class {1}.";
		private static const EMPTY:String = '';

		/** The number of generated components by scanning, used to generate unique object names. */
		private static var _numScannedComponents:uint = 0;

		/**
		 * Creates a new <code>MetadataObjectDefinitionsProvider</code> instance.
		 */
		public function MetadataObjectDefinitionsProvider() {
			super();
			_internalRegistry = new DefaultObjectDefinitionRegistry();
		}

		private var _applicationContext:IApplicationContext;
		private var _classBeingScanned:Vector.<Class>;
		private var _isDisposed:Boolean;
		private var _objectDefinitions:Object;
		private var _internalRegistry:IObjectDefinitionRegistry;
		private var _propertiesProvider:IPropertiesProvider;
		private var _propertyURIs:Vector.<TextFileURI>;

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
			_objectDefinitions = createObjectDefinitions(ByteCodeType.getCache());
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function dispose():void {
			if (!_isDisposed) {
				_isDisposed = true;
			}
		}

		protected function createObjectDefinitions(cache:ByteCodeTypeCache):Object {
			var classNames:Array = cache.getClassesWithMetadata(COMPONENT_METADATA);
			_classBeingScanned = getClassesFromClassNames(classNames);
			for each (var className:String in classNames) {
				scan(className);
			}
			var result:Object;
			var names:Vector.<String> = _internalRegistry.objectDefinitionNames;
			for each (var name:String in _internalRegistry) {
				result ||= {};
				var definition:IObjectDefinition = _internalRegistry.removeObjectDefinition(name);
				definition.registryId = "";
				result[name] = definition;
			}
			return result;
		}

		protected function getClassesFromClassNames(classNames:Array):Vector.<Class> {
			var result:Vector.<Class> = new Vector.<Class>();
			var appDomain:ApplicationDomain;

			if (applicationContext) {
				appDomain = applicationContext.applicationDomain;
			}

			for each (var className:String in classNames) {
				result[result.length] = ClassUtils.forName(className, appDomain);
			}

			return result;
		}

		protected function getComponentIdFromMetaData(metadata:Metadata):String {
			var result:String;

			if (metadata.hasArgumentWithKey(ID_ATTR)) {
				result = metadata.getArgument(ID_ATTR).value;
			} else if (metadata.hasArgumentWithKey(EMPTY)) {
				result = metadata.getArgument(EMPTY).value;
			}

			return result;
		}

		protected function getInterfaceImplementations(interfaze:Class, classes:Vector.<Class>):Vector.<Class> {
			var result:Vector.<Class>;

			for each (var clazz:Class in classes) {
				result ||= new Vector.<Class>();
				if (ClassUtils.isAssignableFrom(interfaze, clazz)) {
					result[result.length] = clazz;
				}
			}

			return result;
		}

		protected function getObjectDefinitionsThatMatchClass(clazz:Class, objectDefinitionId:String, propertyName:String=""):Vector.<String> {
			var result:Vector.<String> = _internalRegistry.getObjectNamesForType(clazz);

			// no definition for class, perhaps the class has not been scanned yet
			if (result != null) {
				// if this clazz is an interface, look up an implementation in the classes that are currently being scanned
				if (ClassUtils.isInterface(clazz)) {
					var implementationClasses:Vector.<Class> = getInterfaceImplementations(clazz, _classBeingScanned);

					if (implementationClasses != null) {
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

		protected function resolveArguments(metadata:Metadata):Array {
			var result:Array = [];

			if (metadata.hasArgumentWithKey(ARGS_ATTR)) {
				var arg:String = metadata.getArgument(ARGS_ATTR).value;
				if (arg.length > 0) {
					var args:Array = arg.split(COMMA);
					var keyvalue:Array;
					for each (var val:String in args) {
						val = StringUtils.trim(val);
						keyvalue = val.split(EQUALS);
						if (StringUtils.trim(keyvalue[0]) == REF_ATTR) {
							result[result.length] = new RuntimeObjectReference(StringUtils.trim(keyvalue[1]));
						} else if (StringUtils.trim(keyvalue[0]) == VALUE_ATTR) {
							result[result.length] = StringUtils.trim(keyvalue[1]);
						}
					}
				}
			}

			return (result.length > 0) ? result : null;
		}

		/**
		 *
		 * @param type
		 * @param definition
		 * @param objectDefinitionId
		 *
		 */
		protected function resolveConstructorArgs(type:Type, definition:IObjectDefinition, objectDefinitionId:String):void {
			if (type.hasMetadata(CONSTRUCTOR_METADATA)) {
				var constructorArguments:Array = resolveArguments(type.getMetadata(CONSTRUCTOR_METADATA)[0]);
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

				for (var i:int = 0; i < numConstructorArgs; i++) {
					var constructorArg:Parameter = type.constructor.parameters[i];
					var constructorArgClass:Class = constructorArg.type.clazz;
					var objectDefinitionsThatMatchConstructorArgClass:Vector.<String> = getObjectDefinitionsThatMatchClass(constructorArgClass, objectDefinitionId);
					var numObjectDefinitions:int = objectDefinitionsThatMatchConstructorArgClass.length;

					if (numObjectDefinitions == 0) {
						throw new Error("Unsatisfied dependency");
					} else if (numObjectDefinitions == 1) {
						definition.constructorArguments ||= [];

						var constructorArgDefinitionId:String = objectDefinitionsThatMatchConstructorArgClass[0];
						definition.constructorArguments.push(new RuntimeObjectReference(constructorArgDefinitionId));
					}

				}
			}
		}

		/**
		 *
		 * @param componentMetaData
		 * @param definition
		 * @param className
		 */
		protected function resolveDefinitionProperties(componentMetaData:Metadata, definition:ObjectDefinition, className:String):void {
			for each (var arg:MetadataArgument in componentMetaData.arguments) {

				switch (arg.key) {
					case SCOPE_ATTR:
						definition.scope = ObjectDefinitionScope.fromName(arg.value);
						break;
					case LAZY_INIT_ATTR:
						definition.isLazyInit = (arg.value == TRUE_VALUE);
						break;
					case PRIMARY_ATTR:
						definition.primary = (arg.value == TRUE_VALUE);
						break;
					case AUTOWIRE_CANDIDATE_ATTR:
						definition.isAutoWireCandidate = (arg.value == TRUE_VALUE);
						break;
					case SKIP_METADATA_ATTR:
						definition.skipMetadata = (arg.value == TRUE_VALUE);
						break;
					case SKIP_POSTPROCESSORS_ATTR:
						definition.skipPostProcessors = (arg.value == TRUE_VALUE);
						break;
					case FACTORY_METHOD_ATTR:
						definition.factoryMethod = arg.value;
						break;
					case FACTORY_OBJECT_NAME_ATTR:
						definition.factoryObjectName = arg.value;
						break;
					case INIT_METHOD_ATTR:
						definition.initMethod = arg.value;
						break;
					case DESTROY_METHOD_ATTR:
						definition.destroyMethod = arg.value;
					case AUTOWIRE_ATTR:
						definition.autoWireMode = AutowireMode.fromName(arg.value);
						break;
					case DEPENDENCY_CHECK_ATTR:
						definition.dependencyCheck = DependencyCheckMode.fromName(arg.value);
					case DEPENDS_ON_ATTR:
						var depends:Array = arg.value.split(' ').join(EMPTY).split(COMMA);
						definition.dependsOn = new Vector.<String>();
						for each (var name:String in depends) {
							definition.dependsOn[definition.dependsOn.length] = name;
						}
						break;
					case PARENT_NAME_ATTR:
						definition.parentName = arg.value;
						break;
					case IS_ABSTRACT_ATTR:
						definition.isAbstract = (arg.value == TRUE_VALUE);
					case ID_ATTR:
						break;
					default:
						LOGGER.debug(UNKNOWN_METADATA_ARGUMENT_ERROR, [arg.key, className]);
				}
			}
		}

		/**
		 *
		 * @param type
		 * @param definition
		 */
		protected function resolveMethods(type:Type, definition:IObjectDefinition):void {
			var containers:Array = type.getMetadataContainers(INVOKE_METADATA);
			for each (var container:IMetadataContainer in containers) {
				if (container is Method) {
					addMethod(Method(container), definition);
				}
			}
		}

		/**
		 *
		 * @param method
		 * @param definition
		 */
		protected function addMethod(method:Method, definition:IObjectDefinition):void {
			var metadata:Metadata = method.getMetadata(INVOKE_METADATA)[0];
			var arguments:Array = resolveArguments(metadata);
			var mv:MethodInvocation = new MethodInvocation(method.name, arguments, method.namespaceURI);
			definition.addMethodInvocation(mv);
		}

		/**
		 *
		 * @param className
		 */
		protected function scan(className:String):void {
			var clazz:Class = ClassUtils.forName(className, applicationContext.applicationDomain);

			var type:Type = Type.forClass(clazz, applicationContext.applicationDomain);

			LOGGER.debug(SCANNING_CLASS, [className]);

			if (type.hasMetadata(COMPONENT_METADATA)) {
				var metadata:Array = type.getMetadata(COMPONENT_METADATA);

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
					_applicationContext.objectDefinitionRegistry.registerObjectDefinition(componentId, definition);
					definition.isSingleton = !ClassUtils.isSubclassOf(clazz, DisplayObject, applicationContext.applicationDomain);
					resolveDefinitionProperties(componentMetaData, definition, className);

					if (componentId == null) {
						componentId = SCANNED_COMPONENT_NAME_PREFIX + ++_numScannedComponents;
					}

					resolveConstructorArgs(type, definition, componentId);
					resolveMethods(type, definition);

						//resolveProperties(type, definition, componentId);
						//resolvePropertyPlaceholdersForObjectDefinition(_resolver, definition);


				}
			}

		}
	}
}