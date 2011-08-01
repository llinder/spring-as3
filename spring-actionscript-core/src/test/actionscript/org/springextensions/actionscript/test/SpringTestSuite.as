package org.springextensions.actionscript.test {
	import org.springextensions.actionscript.ioc.factory.impl.DefaultInstanceCacheTest;
	import org.springextensions.actionscript.util.TypeUtilsTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class SpringTestSuite {
		public var t1:DefaultInstanceCacheTest;
		public var t2:TypeUtilsTest;
	}
}
