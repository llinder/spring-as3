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
package org.springextensions.actionscript.context.impl {
	import flash.display.DisplayObject;
	import flash.events.Event;

	import org.as3commons.eventbus.impl.EventBus;
	import org.as3commons.lang.ClassUtils;
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.eventbus.process.EventBusAwareObjectPostProcessor;
	import org.springextensions.actionscript.ioc.autowire.impl.DefaultAutowireProcessor;
	import org.springextensions.actionscript.ioc.factory.IObjectFactory;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultInstanceCache;
	import org.springextensions.actionscript.ioc.factory.impl.DefaultObjectFactory;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ArrayCollectionReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ArrayReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.DictionaryReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ObjectReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.ThisReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.impl.referenceresolver.VectorReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.FactoryObjectFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.ObjectDefinitonFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.RegisterObjectFactoryPostProcessorsFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.RegisterObjectPostProcessorsFactoryPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.object.ApplicationContextAwareObjectPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.object.ApplicationDomainAwarePostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.object.ObjectDefinitionRegistryAwareObjectPostProcessor;
	import org.springextensions.actionscript.ioc.factory.process.impl.object.ObjectFactoryAwarePostProcessor;
	import org.springextensions.actionscript.ioc.impl.DefaultDependencyInjector;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.DefaultObjectDefinitionRegistry;
	import org.springextensions.actionscript.ioc.objectdefinition.impl.ObjectDefinition;
	import org.springextensions.actionscript.metadata.MetadataProcessorObjectFactoryPostProcessor;
	import org.springextensions.actionscript.metadata.processor.PostConstructMetadataProcessor;
	import org.springextensions.actionscript.metadata.processor.PreDestroyMetadataProcessor;
	import org.springextensions.actionscript.stage.StageProcessorFactoryPostprocessor;

	[Event(name="complete", type="flash.events.Event")]
	/**
	 *
	 * @author Roland Zwaga
	 */
	public class DefaultApplicationContext extends ApplicationContext {

		/**
		 * Creates a new <code>ApplicationContext</code> instance.
		 * @param parent
		 * @param objFactory
		 */
		public function DefaultApplicationContext(parent:IApplicationContext=null, rootViews:Vector.<DisplayObject>=null, objFactory:IObjectFactory=null) {
			objectFactory = objFactory ||= createDefaultObjectFactory(parent);
			super(parent, rootViews, objFactory);
			initApplicationContext();
		}

		/**
		 *
		 * @param parent
		 * @param rootView
		 * @param objFactory
		 */
		protected function initApplicationContext():void {
			addObjectFactoryPostProcessor(new RegisterObjectPostProcessorsFactoryPostProcessor(-100));
			addObjectFactoryPostProcessor(new RegisterObjectFactoryPostProcessorsFactoryPostProcessor(-99));
			addObjectFactoryPostProcessor(new ObjectDefinitonFactoryPostProcessor(1000));
			addObjectFactoryPostProcessor(new StageProcessorFactoryPostprocessor());
			addObjectFactoryPostProcessor(new MetadataProcessorObjectFactoryPostProcessor());
			addObjectFactoryPostProcessor(new FactoryObjectFactoryPostProcessor());

			if (objectFactory.objectDefinitionRegistry != null) {
				var definition:IObjectDefinition = new ObjectDefinition(ClassUtils.getFullyQualifiedName(PostConstructMetadataProcessor, true));
				objectFactory.objectDefinitionRegistry.registerObjectDefinition("springactionscript_postConstructProcessor", definition);
				definition = new ObjectDefinition(ClassUtils.getFullyQualifiedName(PreDestroyMetadataProcessor, true));
				objectFactory.objectDefinitionRegistry.registerObjectDefinition("springactionscript_preDestroyProcessor", definition);
			}

			objectFactory.addObjectPostProcessor(new ApplicationContextAwareObjectPostProcessor(this));
			objectFactory.addObjectPostProcessor(new ApplicationDomainAwarePostProcessor(this));
			objectFactory.addObjectPostProcessor(new ObjectFactoryAwarePostProcessor(this));
			objectFactory.addObjectPostProcessor(new EventBusAwareObjectPostProcessor(this));
			objectFactory.addObjectPostProcessor(new ObjectDefinitionRegistryAwareObjectPostProcessor(this.objectDefinitionRegistry));

			objectFactory.addReferenceResolver(new ThisReferenceResolver(this));
			objectFactory.addReferenceResolver(new ObjectReferenceResolver(this));
			objectFactory.addReferenceResolver(new ArrayReferenceResolver(this));
			objectFactory.addReferenceResolver(new DictionaryReferenceResolver(this));
			objectFactory.addReferenceResolver(new VectorReferenceResolver(this));
			if (ArrayCollectionReferenceResolver.canCreate(applicationDomain)) {
				objectFactory.addReferenceResolver(new ArrayCollectionReferenceResolver(this));
			}
		}

		/**
		 *
		 * @param parent
		 * @return
		 */
		protected function createDefaultObjectFactory(parent:IApplicationContext):IObjectFactory {
			var defaultObjectFactory:DefaultObjectFactory = new DefaultObjectFactory(parent);
			defaultObjectFactory.cache = new DefaultInstanceCache();
			defaultObjectFactory.objectDefinitionRegistry = new DefaultObjectDefinitionRegistry();
			defaultObjectFactory.eventBus = new EventBus();
			defaultObjectFactory.dependencyInjector = new DefaultDependencyInjector();
			var autowireProcessor:DefaultAutowireProcessor = new DefaultAutowireProcessor(this);
			defaultObjectFactory.autowireProcessor = autowireProcessor;
			return defaultObjectFactory;
		}

	}
}
