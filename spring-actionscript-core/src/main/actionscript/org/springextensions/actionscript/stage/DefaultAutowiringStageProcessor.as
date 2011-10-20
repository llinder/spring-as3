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
package org.springextensions.actionscript.stage {
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;

	import org.as3commons.lang.Assert;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.lang.IDisposable;
	import org.as3commons.lang.StringUtils;
	import org.as3commons.stageprocessing.IStageObjectDestroyer;
	import org.as3commons.stageprocessing.IStageObjectProcessor;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.ioc.factory.IInitializingObject;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;

	/**
	 * <code>IStageProcessor</code> implementation that is created by default by the <code>FlexXMLApplicationContext</code> to perform
	 * autowiring and dependency injection on stage components.
	 * @author Roland Zwaga
	 * @see org.springextensions.actionscript.context.support.FlexXMLApplicationContext FlexXMLApplicationContext
	 * @docref container-documentation.html#autowiring_stage_components
	 * @sampleref stagewiring
	 */
	public class DefaultAutowiringStageProcessor implements IApplicationContextAware, IStageObjectProcessor, IDisposable, IInitializingObject {
		{
			DefaultObjectDefinitionResolver;
		}

		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------

		/**
		 * Creates a new <code>DefaultAutowiringStageProcessor</code> instance.
		 */
		public function DefaultAutowiringStageProcessor() {
			super();
			componentCache = new Dictionary(true);
			autowireOnce = true;
			_objectDefinitionResolver = null;
		}

		/**
		 * A Dictionary instance used to keep track of the stage components that have already been
		 * processed by the current <code>DefaultAutowiringStageProcessor</code>. This <code>Dictionary</code>
		 * instance is created with the <code>weakKeys</code> constructor argument set to <code>true</code>
		 * and will therefore not cause any memory leaks should any of the components be removed
		 * from the stage permanently.
		 * @see org.springextensions.actionscript.stage.DefaultAutowiringStageProcessor#autowireOnce DefaultAutowiringStageProcessor.autowireOnce
		 */
		protected var componentCache:Dictionary;

		private var _applicationContext:IApplicationContext;
		private var _autowireOnce:Boolean = true;
		private var _objectDefinitionResolver:IObjectDefinitionResolver;

		// --------------------------------------------------------------------
		//
		// Properties
		//
		// --------------------------------------------------------------------
		private var _isDisposed:Boolean;


		public function get applicationContext():IApplicationContext {
			return _applicationContext;
		}

		/**
		 * <p><code>IObjectFactory</code> instance whose <code>wire()</code> method will be invoked in the <code>process()</code> method.</p>
		 * @inheritDoc
		 */
		public function set applicationContext(applicationContext:IApplicationContext):void {
			_applicationContext = applicationContext;
		}

		/**
		 * Determines whether an object will be autowired again when it is passed to the <code>process()</code> method more than once.
		 * @default true
		 */
		public function get autowireOnce():Boolean {
			return _autowireOnce;
		}

		/**
		 * @private
		 */
		public function set autowireOnce(value:Boolean):void {
			_autowireOnce = value;
		}

		/**
		 * An <code>IObjectDefinitionResolver</code> to retrieve <code>IObjectDefinition</code>
		 * used for stage object wiring.
		 * @default DefaultObjectDefinitionResolver
		 */
		public function get objectDefinitionResolver():IObjectDefinitionResolver {
			return _objectDefinitionResolver;
		}

		/**
		 * @private
		 */
		public function set objectDefinitionResolver(value:IObjectDefinitionResolver):void {
			_objectDefinitionResolver = value;
		}

		public function dispose():void {
			if (!_isDisposed) {
				componentCache = null;
				_isDisposed = true;
			}
		}

		// --------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------

		/**
		 * Invokes the <code>wire()</code> method on the <code>objectFactory</code> property with the specified
		 * <code>object</code>.
		 *
		 * <p>The <code>objectDefinitionResolver</code> is used to retrieve an appropriate
		 * <code>IObjectDefinition</code> instance for the specified <code>object</code>.</p>
		 *
		 * @see org.springextensions.actionscript.stage.IObjectSelector IObjectSelector
		 * @see org.springextensions.actionscript.stage.IObjectDefinitionResolver IObjectDefinitionResolver
		 * @inheritDoc
		 */
		public function process(displayObject:DisplayObject):DisplayObject {
			if ((!componentCache[displayObject] && _autowireOnce) || !_autowireOnce) {
				if (_applicationContext) {
					componentCache[displayObject] = true;
					var objectDefinition:IObjectDefinition = (_objectDefinitionResolver ? _objectDefinitionResolver.resolveObjectDefinition(displayObject) : null);
					_applicationContext.dependencyInjector.wire(displayObject, _applicationContext, objectDefinition);
					var objectName:String = (objectDefinition != null) ? _applicationContext.objectDefinitionRegistry.getObjectDefinitionName(objectDefinition) : null;
					if (_applicationContext.objectDestroyer != null) {
						_applicationContext.objectDestroyer.registerInstance(displayObject, objectName);
					}
				}
			}
			return displayObject;
		}

		public function toString():String {
			return "[DefaultAutowiringStageProcessor(autowireOnce=" + autowireOnce + ")]";
		}

		public function get isDisposed():Boolean {
			return _isDisposed;
		}

		public function afterPropertiesSet():void {
			if (_objectDefinitionResolver == null) {
				var names:Vector.<String> = _applicationContext.objectDefinitionRegistry.getObjectNamesForType(IObjectDefinitionResolver);
				if (names != null) {
					_objectDefinitionResolver = _applicationContext.getObject(names[0]);
				}
			}
		}
	}
}
