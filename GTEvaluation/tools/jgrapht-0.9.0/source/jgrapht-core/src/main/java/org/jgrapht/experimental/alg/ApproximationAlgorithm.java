/* This program and the accompanying materials are dual-licensed under
 * either
 *
 * (a) the terms of the GNU Lesser General Public License version 2.1
 * as published by the Free Software Foundation, or (at your option) any
 * later version.
 *
 * or (per the licensee's choosing)
 *
 * (b) the terms of the Eclipse Public License v1.0 as published by
 * the Eclipse Foundation.
 */
package org.jgrapht.experimental.alg;

import java.util.*;


public interface ApproximationAlgorithm<ResultType, V>
{
    

    ResultType getUpperBound(Map<V, Object> optionalData);

    ResultType getLowerBound(Map<V, Object> optionalData);

    boolean isExact();
}

// End ApproximationAlgorithm.java
