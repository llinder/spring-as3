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

	/**
	 *
	 * @author Roland Zwaga
	 */
	public interface IEventBusUserRegistry {
		function addEventListeners(eventDispatcher:IEventDispatcher, eventTypes:Array, topics:Array):void;
		function removeListeners(eventDispatcher:IEventDispatcher):void;
		function addEventListenerProxy(type:String, proxy:MethodInvoker, useWeakReference:Boolean=false, topic:Object=null):Boolean;
		function addEventClassListenerProxy(eventClass:Class, proxy:MethodInvoker, useWeakReference:Boolean=false, topic:Object=null):Boolean;

		function addInterceptor(interceptor:IEventInterceptor, topic:Object=null):void;
		function addEventInterceptor(type:String, interceptor:IEventInterceptor, topic:Object=null):void;
		function addEventClassInterceptor(eventClass:Class, interceptor:IEventInterceptor, topic:Object=null):void;

		function addListenerInterceptor(interceptor:IEventListenerInterceptor, topic:Object=null):void;
		function addEventListenerInterceptor(type:String, interceptor:IEventListenerInterceptor, topic:Object=null):void;
		function addEventClassListenerInterceptor(eventClass:Class, interceptor:IEventListenerInterceptor, topic:Object=null):void;
	}
}
