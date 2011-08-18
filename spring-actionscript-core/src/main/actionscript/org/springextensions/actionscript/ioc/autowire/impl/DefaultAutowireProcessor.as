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
package org.springextensions.actionscript.ioc.autowire.impl {

	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	import org.as3commons.lang.Assert;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IApplicationDomainAware;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.reflect.Accessor;
	import org.as3commons.reflect.AccessorAccess;
	import org.as3commons.reflect.Field;
	import org.as3commons.reflect.Metadata;
	import org.as3commons.reflect.Parameter;
	import org.as3commons.reflect.Type;
	import org.as3commons.reflect.Variable;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.ioc.autowire.AutowireMode;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessor;
	import org.springextensions.actionscript.ioc.autowire.IAutowireProcessorAware;
	import org.springextensions.actionscript.ioc.error.UnsatisfiedDependencyError;
	import org.springextensions.actionscript.ioc.factory.IFactoryObject;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.IObjectFactoryAware;
	import org.springextensions.actionscript.ioc.factory.NoSuchObjectDefinitionError;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory;
	import org.springextensions.actionscript.ioc.objectdefinition.DependencyCheckMode;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.util.TypeUtils;

	/**
	 * <p>Default <code>IAutowireProcessor</code> implementation used by the <code>AbstractObjectFactory</code>.</p>
	 * @see org.springextensions.actionscript.ioc.factory.support.AbstractObjectFactory AbstractObjectFactory
	 * @author Martino Piccinato
	 * @author Roland Zwaga
	 * @sampleref stagewiring
	 * @docref container-documentation.html#autowiring_stage_components
	 * @inheritDoc
	 */
	public class DefaultAutowireProcessor implements IAutowireProcessor, IObjectFactoryAware, IApplicationDomainAware, IDisposable {

		// --------------------------------------------------------------------
		//
		// Public Constants
		//
		// --------------------------------------------------------------------
		/**
		 * The name of the metadata that determines whether a field needs to be autowired
		 */
		public static const AUTOWIRED_ANNOTATION:String = "Autowired";

		/**
		 * The name of the metadata argument that determines the name of a property in the container that needs to be injected into the specified field
		 */
		public static const AUTOWIRED_ARGUMENT_EXTERNALPROPERTY:String = "externalProperty";

		/**
		 * The name of the metadata argument that determines the autowiring strategy, possibles values are 'autodetect', 'byName', 'byType', 'constructor' or 'no'
		 */
		public static const AUTOWIRED_ARGUMENT_MODE:String = "mode";

		/**
		 * The name of the metadata argument that determines the name of the object in the container that needs to be injected into the specified field
		 */
		public static const AUTOWIRED_ARGUMENT_NAME:String = "name";

		/**
		 * The name of the metadata argument that determines whether the dependency is required or not.
		 */
		public static const AUTOWIRED_ARGUMENT_REQUIRED:String = "required";
		/**
		 *
		 */
		public static const AUTOWIRING_ERROR:String = "An error occured while autowiring '{0}'.{1}' with '{2}'. Caused by: {3}. {4}";
		/**
		 * The name of the metadata that determines whether a field needs to be autowired
		 */
		public static const INJECT_ANNOTATION:String = "Inject";
		/**
		 *
		 */
		public static const MULTIPLE_PRIMARY_CANIDATES_ERROR:String = "More than one 'primary' object found among candidates: {0}";
		/**
		 *
		 */
		public static const TRUE_VALUE:String = 'true';

		// --------------------------------------------------------------------
		//
		// Private Static Fields
		//
		// --------------------------------------------------------------------

		private static const logger:ILogger = getLogger(DefaultAutowireProcessor);

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>DefaultAutowireProcessor</code> instance.
		 */
		public function DefaultAutowireProcessor(objectFactory:IObjectFactory) {
			initDefaultAutowireProcessor(objectFactory);
		}

		private var _applicationDomain:ApplicationDomain;
		private var _autowireMetadataNames:Vector.<String>;

		// --------------------------------------------------------------------
		//
		// Properties
		//
		// --------------------------------------------------------------------

		// ----------------------------
		// objectFactory
		// ----------------------------

		private var _objectFactory:IObjectFactory;
		private var _processDefinitions:Dictionary;
		private var _isDisposed:Boolean;

		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}

		// --------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------

		/**
		 * <p>Method called during object creation. Will autowire unclaimed non simple properties by type or by name if required by the
		 * object definition.</p>
		 * @see org.springextensions.actionscript.ioc.factory.support.AbstractObjectFactory#getObject()
		 * @see org.springextensions.actionscript.ioc.AutowireMode AutowireMode
		 * @inheritDoc
		 */
		public function autoWire(object:Object, objectDefinition:IObjectDefinition=null, objectName:String=null):void {
			Assert.notNull(object, "The object parameter must not be null");
			Assert.notNull(_objectFactory, "The objectFactory property must not be null");

			if (objectDefinition != null) {
				switch (objectDefinition.autoWireMode) {
					case AutowireMode.NO:
						// No autowire
						break;
					case AutowireMode.BYNAME:
						this.autoWireByName(object, objectDefinition);
						break;
					case AutowireMode.BYTYPE:
						this.autoWireByType(object, objectDefinition);
						break;
					default:
						// No autowire
				}
			}

			if ((objectDefinition == null) || (!objectDefinition.skipMetadata)) {
				// Process autowire annotations
				var unclaimedProperties:Vector.<Field> = getUnclaimedSimpleObjectProperties(object, objectDefinition);
				for each (var field:Field in unclaimedProperties) {
					if ((field.hasMetadata(AUTOWIRED_ANNOTATION)) || (field.hasMetadata(INJECT_ANNOTATION))) {
						try {
							autoWireField(object, field, objectName);
						} catch (err:UnsatisfiedDependencyError) {
							if (isFieldAutowireRequired(field)) {
								logger.error("Error while autowiring property {2} of object {1}: {0}", [err.message, field.name, objectName]);
								throw err;
							}
							logger.warn("Error while autowiring property {2} of object {1}: {0}", [err.message, field.name, objectName]);
						}
					}
				}
			}
		}

		public function get autowireMetadataNames():Vector.<String> {
			if (_autowireMetadataNames == null) {
				_autowireMetadataNames = new Vector.<String>();
				_autowireMetadataNames[_autowireMetadataNames.length] = AUTOWIRED_ANNOTATION;
				_autowireMetadataNames[_autowireMetadataNames.length] = INJECT_ANNOTATION;
			}
			return _autowireMetadataNames;
		}

		public function set autowireMetadataNames(value:Vector.<String>):void {
			_autowireMetadataNames = value;
		}

		/**
		 * @inheritDoc
		 */
		public function findAutowireCandidateName(clazz:Class):String {
			var candidateNames:Vector.<String> = findAutowireCandidateNames(clazz);
			if (candidateNames.length < 1) {
				var proc:IAutowireProcessorAware = (_objectFactory.parent as IAutowireProcessorAware);
				if ((proc != null) && (proc.autowireProcessor != null)) {
					return proc.autowireProcessor.findAutowireCandidateName(clazz);
				}
			}

			var finalCandidateName:String = null;
			if (candidateNames.length > 1) {
				finalCandidateName = determinePrimaryCandidate(candidateNames);
			} else if (candidateNames.length == 1) {
				finalCandidateName = candidateNames[0];
			}

			return finalCandidateName;
		}

		/**
		 * @private
		 */
		public function get objectFactory():IObjectFactory {
			return _objectFactory;
		}

		/**
		 * @inheritDoc
		 */
		public function set objectFactory(value:IObjectFactory):void {
			Assert.notNull(value, "The objectFactory property must not be null");
			_objectFactory = value;
		}

		/**
		 * <p>Performs <code>AUTODETECT</code> and <code>CONSTRUCTOR</code> checks.</p>
		 * @see org.springextensions.actionscript.ioc.AutowireMode#AUTODETECT AUTODETECT
		 * @see org.springextensions.actionscript.ioc.AutowireMode#CONSTRUCTOR CONSTRUCTOR
		 * @inheritDoc
		 * @docref container-documentation.html#autowiring_objects
		 */
		public function preprocessObjectDefinition(objectDefinition:IObjectDefinition):void {
			Assert.notNull(objectDefinition, "The objectDefinition parameter must not be null");
			if (_processDefinitions[objectDefinition] != null) {
				return;
			}
			_processDefinitions[objectDefinition] = true;
			var type:Type = Type.forName(objectDefinition.className, _objectFactory.applicationDomain);

			// If configured as AUTODETECT we must decide here whether
			// to use CONSTRUCTOR or BYTYPE
			if (objectDefinition.autoWireMode == AutowireMode.AUTODETECT) {
				if (type.constructor.hasNoArguments()) {
					objectDefinition.autoWireMode = AutowireMode.BYTYPE;
				} else {
					objectDefinition.autoWireMode = AutowireMode.CONSTRUCTOR;
				}
			}

			// If configured, use CONSTRUCTOR only if no explicit constructor
			// arguments are passed to the method and no constructor parameter are
			// explicitly set in the object definition
			if ((!objectDefinition.constructorArguments || objectDefinition.constructorArguments.length == 0) && objectDefinition.autoWireMode == AutowireMode.CONSTRUCTOR) {
				objectDefinition.constructorArguments ||= [];
				var idx:uint = 0;
				for each (var parameter:Parameter in type.constructor.parameters) {
					var isSimple:Boolean = TypeUtils.isSimpleProperty(parameter.type);
					var candidateName:String = findAutowireCandidateName(parameter.type.clazz);
					if (((isSimple) && (candidateName == null) && ((objectDefinition.dependencyCheck === DependencyCheckMode.ALL) || (objectDefinition.dependencyCheck === DependencyCheckMode.SIMPLE))) || //
						((!isSimple) && (candidateName == null) && ((objectDefinition.dependencyCheck === DependencyCheckMode.ALL) || (objectDefinition.dependencyCheck === DependencyCheckMode.OBJECTS)))) {
						throw new UnsatisfiedDependencyError("(autowired object)", "constructor argument #" + idx, "Constructor argument could not be resolved during autowiring");
					}
					objectDefinition.constructorArguments[objectDefinition.constructorArguments.length] = candidateName;
					idx++;
				}
			}
		}

		/**
		 * Called by autoWire method in case of autowire by name.
		 *
		 * @see #autoWire(Object, IObjectDefinition)
		 */
		protected function autoWireByName(object:Object, objectDefinition:IObjectDefinition):void {
			var fields:Vector.<Field> = getUnclaimedSimpleObjectProperties(object, objectDefinition);
			var numFields:int = fields.length;
			var fieldName:String;

			for (var n:int = 0; n < numFields; n++) {
				fieldName = fields[n].name;

				if (containsObject(fieldName) && getObjectDefinition(fieldName).isAutoWireCandidate) {
					setField(object, null, fieldName, fieldName);
				}
			}
		}

		/**
		 * Called by autoWire method in case of autowire by type.
		 *
		 * @see #autoWire(Object, IObjectDefinition)
		 */
		protected function autoWireByType(object:Object, objectDefinition:IObjectDefinition):void {
			var properties:Vector.<Field> = getUnclaimedSimpleObjectProperties(object, objectDefinition);
			var numProperties:int = properties.length;
			var finalCandidateName:String;
			var property:Field;

			for (var i:int = 0; i < numProperties; i++) {
				property = properties[i];
				finalCandidateName = findAutowireCandidateName(property.type.clazz);

				if (finalCandidateName) {
					setField(object, null, property.name, finalCandidateName);
				} else {
					if (property.type.clazz === ApplicationDomain) {
						object[property.name] = _objectFactory.applicationDomain;
					} else if ((property.type.clazz === IApplicationContext) || (property.type.clazz === IObjectFactory)) {
						object[property.name] = _objectFactory;
					}
				}
			}
		}

		// --------------------------------------------------------------------
		//
		// Protected Methods
		//
		// --------------------------------------------------------------------

		/**
		 * Checks of the specified <code>Field</code> instance contains any autowiring metadata, abd based
		 * on this class the appropriate wiring methods.
		 * @param object The object being autowired
		 * @param field The field that will be examined for the necessary metadata
		 * @param objectName The name of the object in the objectFactory
		 */
		protected function autoWireField(object:Object, field:Field, objectName:String):void {
			var fieldMetaData:Array = getAutowireSpecificMetadata(field);
			if (fieldMetaData == null) {
				return;
			}

			for each (var metadata:Metadata in fieldMetaData) {
				if (((metadata.hasArgumentWithKey(AUTOWIRED_ARGUMENT_MODE) && metadata.getArgument(AUTOWIRED_ARGUMENT_MODE).value == AutowireMode.BYNAME.name)) || (metadata.hasArgumentWithKey(AUTOWIRED_ARGUMENT_NAME) || metadata.hasArgumentWithKey(""))) {
					autoWireFieldByName(object, field, metadata, objectName);
				} else if (metadata.hasArgumentWithKey(AUTOWIRED_ARGUMENT_EXTERNALPROPERTY)) {
					autoWireFieldByPropertyName(object, field, metadata, objectName);
				} else {
					autoWireFieldByType(object, field, metadata, objectName);
				}
			}
		}

		/**
		 * Takes the field name or the value of the <code>AUTOWIRED_ARGUMENT_NAME</code> metadata argument, retrieves the
		 * object with that name form the <code>objectFactory</code> and injects it into the specified field.
		 * @param object The object being autowired
		 * @param field The field that will be injected
		 * @param metadata The autowiring metadata
		 * @param objectName The name of the object in the objectFactory
		 */
		protected function autoWireFieldByName(object:Object, field:Field, metadata:Metadata, objectName:String):void {
			var name:String = field.name;
			if (metadata.hasArgumentWithKey(AUTOWIRED_ARGUMENT_NAME)) {
				name = metadata.getArgument(AUTOWIRED_ARGUMENT_NAME).value;
			} else if (metadata.hasArgumentWithKey("")) {
				name = metadata.getArgument("").value;
			}

			logger.debug("Autowiring by name '{0}.{1}' with '{2}'", [objectName, field.name, name]);
			try {
				setField(object, objectName, field.name, name);
			} catch (err:Error) {
				throw new UnsatisfiedDependencyError(objectName, field.name, "Can't autowire property by name: ");
			}

		}

		/**
		 * Takes the value of the <code>AUTOWIRED_ARGUMENT_EXTERNALPROPERTY</code> metadata argument, looks up the
		 * key in the <code>objectFactory</code>'s Properties array and injects it into the specified field.
		 * @param object The object being autowired
		 * @param field The field that will be injected
		 * @param metadata The autowiring metadata
		 * @param objectName The name of the object in the objectFactory
		 *
		 */
		protected function autoWireFieldByPropertyName(object:Object, field:Field, metadata:Metadata, objectName:String):void {
			var key:String = metadata.getArgument(AUTOWIRED_ARGUMENT_EXTERNALPROPERTY).value;
			logger.debug("Autowiring by propertyName '{0}.{1}' with property '{2}'", [objectName, field.name, key]);

			if (_objectFactory.propertiesProvider != null) {
				if (_objectFactory.propertiesProvider.hasProperty(key)) {
					object[field.name] = _objectFactory.propertiesProvider.getProperty(key);
				} else {
					throw new UnsatisfiedDependencyError(objectName, field.name, "Can't find property referenced in Autowired " + AUTOWIRED_ARGUMENT_EXTERNALPROPERTY + "argument: ");
				}
			} else {
				throw new UnsatisfiedDependencyError(objectName, field.name, "Current IObjectFactory instance doesn't have a valid propertiesProvider property assigned");
			}
		}

		/**
		 * Tries to retrieve an autowire candidate based on the type of the specified field, and when found
		 * injects the candidate into the specified field.
		 * @param object The object being autowired
		 * @param field The field that will be injected.
		 * @param metadata The autowiring metadata
		 * @param objectName The name of the object in the objectFactory
		 */
		protected function autoWireFieldByType(object:Object, field:Field, metadata:Metadata, objectName:String):void {
			var candidateName:String = findAutowireCandidateName(field.type.clazz);

			if (candidateName) {
				logger.debug("Autowiring by type '{0}.{1}' with '{2}'", [objectName, field.name, candidateName]);
				setField(object, objectName, field.name, candidateName);
			} else {
				throw new UnsatisfiedDependencyError(objectName, field.name, "Can't find an autowired candidate: ");
			}
		}

		protected function containsObject(objectName:String):Boolean {
			return _objectFactory.objectDefinitionRegistry.containsObjectDefinition(objectName);
		}

		/**
		 *
		 */
		protected function determinePrimaryCandidate(candidateNames:Vector.<String>):String {
			var result:String;
			var definition:IObjectDefinition;
			var numCandidates:uint = candidateNames.length;

			for (var i:int = 0; i < numCandidates; i++) {
				definition = getObjectDefinition(candidateNames[i]);

				if (definition.primary) {
					if (!result) {
						result = candidateNames[i];
					} else {
						throw new NoSuchObjectDefinitionError(StringUtils.substitute(MULTIPLE_PRIMARY_CANIDATES_ERROR, candidateNames.join()));
					}
				}
			}

			return result;
		}

		/**
		 * Called by autoWireByType to get all object names that
		 * could be used to autowire an object property
		 *
		 * @param clazz The class of the property that needs to get autowired.
		 *
		 * @return an Array containing all autowire candidates names.
		 *
		 * @see #autoWireByType(Object, IObjectDefinition)
		 */
		protected function findAutowireCandidateNames(clazz:Class):Vector.<String> {
			var result:Vector.<String> = new Vector.<String>();
			if (_objectFactory.objectDefinitionRegistry == null) {
				return result;
			}
			var objectDefinition:IObjectDefinition;
			var objectClass:Class;
			var autowiredClassName:String = ClassUtils.getFullyQualifiedName(clazz, true);

			// check each definition and see if it is an autowire candidate for the given clazz
			// note: an autowire candidate must:
			// - have its isAutowireCandidate property set to true
			// - have its class equal to the given class, be a subclass, or implement its interface, or be a factory object that creates the given class

			for each (var objectName:String in _objectFactory.objectDefinitionRegistry.objectDefinitionNames) {
				objectDefinition = _objectFactory.getObjectDefinition(objectName);
				objectClass = ClassUtils.forName(objectDefinition.className, _applicationDomain);

				if (ClassUtils.isImplementationOf(objectClass, IFactoryObject, _objectFactory.applicationDomain)) {
					var factoryObject:IFactoryObject = _objectFactory.getObject(DefaultObjectFactory.OBJECT_FACTORY_PREFIX + objectName);
					objectClass = factoryObject.getObjectType();
				}

				if (objectDefinition.isAutoWireCandidate) {
					if ((objectClass == clazz) || (autowiredClassName == objectDefinition.className) || ClassUtils.isSubclassOf(objectClass, clazz, _objectFactory.applicationDomain) || ClassUtils.isImplementationOf(objectClass, clazz, _objectFactory.applicationDomain) || isFactoryObjectForClass(objectClass, objectName, clazz)) {
						result[result.length] = objectName;
					}
				}
			}

			// explicit singletons
			var cachedNames:Vector.<String> = _objectFactory.cache.getCachedNames();
			for each (var singletonName:String in cachedNames) {
				if (_objectFactory.objectDefinitionRegistry.containsObjectDefinition(singletonName) == false) {
					objectClass = ClassUtils.forInstance(_objectFactory.getObject(singletonName));

					if ((objectClass === clazz) || //
						(autowiredClassName == objectDefinition.className) || //
						ClassUtils.isSubclassOf(objectClass, clazz, _objectFactory.applicationDomain) || //
						ClassUtils.isImplementationOf(objectClass, clazz, _objectFactory.applicationDomain) || //
						isFactoryObjectForClass(objectClass, singletonName, clazz)) {
						result[result.length] = singletonName;
					}
				}
			}

			return result;
		}

		/**
		 * Returns the application domain for the given object.
		 * @param object
		 * @return
		 */
		protected function getApplicationDomain(object:Object):ApplicationDomain {
			return _objectFactory.applicationDomain;
		}

		/**
		 * Checks if any of the metadata names defined by the <code>autowireMetadataNames</code> are present in the specified <code>Field</code>.
		 * @param field
		 * @return
		 */
		protected function getAutowireSpecificMetadata(field:Field):Array {
			for each (var metaDataName:String in autowireMetadataNames) {
				var result:Array = field.getMetadata(metaDataName);
				if (result && (result.length > 0)) {
					return result;
				}
			}
			return null;
		}

		protected function getObjectDefinition(objectName:String):IObjectDefinition {
			Assert.hasText(objectName, "The object name must have text");

			if (_objectFactory.objectDefinitionRegistry.containsObjectDefinition(objectName)) {
				return _objectFactory.getObjectDefinition(objectName);
			} else {
				throw new NoSuchObjectDefinitionError(objectName);
			}
		}


		/**
		 * Used by autowire system in order to find fields eligible for autowiring
		 * @return An <code>Array</code> containing the names of all public variables and readwrite / writeonly accessors.
		 */
		protected function getUnclaimedSimpleObjectProperties(object:Object, objectDefinition:IObjectDefinition):Vector.<Field> {
			var cls:Class = ClassUtils.forInstance(object, _applicationDomain);
			var appDomain:ApplicationDomain = getApplicationDomain(object);
			var type:Type = Type.forClass(cls, appDomain);
			var result:Vector.<Field> = new Vector.<Field>();

			for each (var variable:Variable in type.variables) {
				if (!variable.isStatic && isPropertyUnclaimed(objectDefinition, variable)) {
					result[result.length] = Field(variable);
				}
			}


			for each (var accessor:Accessor in type.accessors) {
				if ((accessor.access === AccessorAccess.WRITE_ONLY || accessor.access === AccessorAccess.READ_WRITE) && !accessor.isStatic && isPropertyUnclaimed(objectDefinition, accessor)) {
					result[result.length] = Field(accessor);
				}
			}

			return result;
		}

		/**
		 * Initializes the current <code>DefaultAutowireProcessor</code>.
		 * @param objectFactory the specified <code>IObjectFactory</code>
		 */
		protected function initDefaultAutowireProcessor(objectFactory:IObjectFactory):void {
			Assert.notNull(objectFactory, "The objectFactory parameter must not be null");
			_objectFactory = objectFactory;
			_processDefinitions = new Dictionary(true);
		}

		/**
		 * Returns if the given factoryObjectClass is a factory object that creates object of the type of objectClass.
		 *
		 * @param factoryObjectClass
		 */
		protected function isFactoryObjectForClass(factoryObjectClass:Class, objectName:String, objectClass:Class):Boolean {
			var isFactoryObject:Boolean = ClassUtils.isImplementationOf(factoryObjectClass, IFactoryObject, _objectFactory.applicationDomain);

			if (isFactoryObject) {
				var factoryObject:IFactoryObject = _objectFactory.getObject(DefaultObjectFactory.OBJECT_FACTORY_PREFIX + objectName);
				return (factoryObject.getObjectType() == objectClass);
			}
			return false;
		}

		/**
		 * @param field The field to check for dependency requirement.
		 * @return <code>true</code> if autowired field dependency is required, <code>false</code>
		 * otherwise.
		 */
		protected function isFieldAutowireRequired(field:Field):Boolean {
			var fieldMetadataArray:Array = getAutowireSpecificMetadata(field);
			for each (var metadata:Metadata in fieldMetadataArray) {
				if (!metadata.hasArgumentWithKey(AUTOWIRED_ARGUMENT_REQUIRED) || metadata.getArgument(AUTOWIRED_ARGUMENT_REQUIRED).value === TRUE_VALUE)
					return true;
			}
			return false;
		}

		/**
		 * Determines if a property is unclaimed by an object definition. Returns
		 * <code>true</code>, if no object definition is passed, or if the object
		 * definition's <code>properties</code> map does not contain a reference
		 * to the passed in field.
		 *
		 * @param objectDefinition The object definition to inspect.
		 * @param field The field to look for on the object definition.
		 * @return <code>true</code> if the field is unclaimed.
		 */
		protected function isPropertyUnclaimed(objectDefinition:IObjectDefinition, field:Field):Boolean {
			return ((objectDefinition == null || objectDefinition.getPropertyDefinitionByName(field.name, field.namespaceURI) == null));
		}

		/**
		 *
		 */
		protected function setField(object:Object, objectName:String, fieldName:String, objectDefinitionName:String):void {
			try {
				object[fieldName] = _objectFactory.getObject(objectDefinitionName);
			} catch (e:Error) {
				if (!objectName) {
					objectName = object.toString();
				}
				throw new Error(StringUtils.substitute(AUTOWIRING_ERROR, objectName, fieldName, objectDefinitionName, e.message, e.getStackTrace()));
			}
		}

		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		public function dispose():void {
			if (!_isDisposed) {
				_objectFactory = null;
				_autowireMetadataNames = null;
				_processDefinitions = null;
				_applicationDomain = null;
				_isDisposed = true;
			}
		}
	}
}
