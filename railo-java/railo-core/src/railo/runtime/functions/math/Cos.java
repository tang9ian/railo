/**
 * Implements the CFML Function cos
 */
package railo.runtime.functions.math;

import railo.runtime.PageContext;
import railo.runtime.ext.function.Function;

public final class Cos implements Function {
	public static double call(PageContext pc , double number) {
		return StrictMath.cos(number);
	}
}