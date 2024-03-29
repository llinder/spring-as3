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
package org.springextensions.actionscript.eventbus {
	import flash.events.IEventDispatcher;
	import org.as3commons.eventbus.IEventInterceptor;
	import org.as3commons.eventbus.IEventListenerInterceptor;
	import org.as3commons.reflect.MethodInvoker;
	import org.springextensions.actionscript.eventbus.process.EventHandlerProxy;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public interface IEventBusUserRegistry {
		function addEventClassInterceptor(eventClass:Class, interceptor:IEventInterceptor, topic:Object=null):void;
		function addEventClassListenerInterceptor(eventClass:Class, interceptor:IEventListenerInterceptor, topic:Object=null):void;
		function addEventClassListenerProxy(eventClass:Class, proxy:MethodInvoker, useWeakReference:Boolean=false, topic:Object=null):Boolean;

		function addEventInterceptor(type:String, interceptor:IEventInterceptor, topic:Object=null):void;

		function addEventListenerInterceptor(type:String, interceptor:IEventListenerInterceptor, topic:Object=null):void;
		function addEventListenerProxy(type:String, proxy:MethodInvoker, useWeakReference:Boolean=false, topic:Object=null):Boolean;
		function addEventListeners(eventDispatcher:IEventDispatcher, eventTypes:Vector.<String>, topics:Array):void;

		function addInterceptor(interceptor:IEventInterceptor, topic:Object=null):void;
		function addListenerInterceptor(interceptor:IEventListenerInterceptor, topic:Object=null):void;

		function removeEventClassInterceptor(eventClass:Class, interceptor:IEventInterceptor, topic:Object=null):void;
		function removeEventClassListenerInterceptor(eventClass:Class, interceptor:IEventListenerInterceptor, topic:Object=null):void;
		function removeEventClassListenerProxy(eventClass:Class, proxy:MethodInvoker, topic:Object=null):void;

		function removeEventInterceptor(type:String, interceptor:IEventInterceptor, topic:Object=null):void;

		function removeEventListenerInterceptor(type:String, interceptor:IEventListenerInterceptor, topic:Object=null):void;
		function removeEventListenerProxy(type:String, proxy:MethodInvoker, topic:Object=null):void;
		function removeInterceptor(interceptor:IEventInterceptor, topic:Object=null):void;

		function removeListenerInterceptor(interceptor:IEventListenerInterceptor, topic:Object=null):void;
		function removeEventListeners(eventDispatcher:IEventDispatcher):void;
	}
}
