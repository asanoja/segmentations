/* ==========================================
 * JGraphT : a free Java graph-theory library
 * ==========================================
 *
 * Project Info:  http://jgrapht.sourceforge.net/
 * Project Creator:  Barak Naveh (http://sourceforge.net/users/barak_naveh)
 *
 * (C) Copyright 2003-2009, by Barak Naveh and Contributors.
 *
 * This program and the accompanying materials are dual-licensed under
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
/* -------------------------
 * DirectedGraphUnion.java
 * -------------------------
 * (C) Copyright 2009-2009, by Ilya Razenshteyn
 *
 * Original Author:  Ilya Razenshteyn and Contributors.
 *
 * $Id$
 *
 * Changes
 * -------
 * 02-Feb-2009 : Initial revision (IR);
 *
 */
package org.jgrapht.graph;

import java.util.*;

import org.jgrapht.*;
import org.jgrapht.util.*;


public class DirectedGraphUnion<V, E>
    extends GraphUnion<V, E, DirectedGraph<V, E>>
    implements DirectedGraph<V, E>
{
    

    private static final long serialVersionUID = -740199233080172450L;

    

    public DirectedGraphUnion(
        DirectedGraph<V, E> g1,
        DirectedGraph<V, E> g2,
        WeightCombiner operator)
    {
        super(g1, g2, operator);
    }

    public DirectedGraphUnion(DirectedGraph<V, E> g1, DirectedGraph<V, E> g2)
    {
        super(g1, g2);
    }

    

    public int inDegreeOf(V vertex)
    {
        Set<E> res = incomingEdgesOf(vertex);
        return res.size();
    }

    public Set<E> incomingEdgesOf(V vertex)
    {
        Set<E> res = new HashSet<E>();
        if (getG1().containsVertex(vertex)) {
            res.addAll(getG1().incomingEdgesOf(vertex));
        }
        if (getG2().containsVertex(vertex)) {
            res.addAll(getG2().incomingEdgesOf(vertex));
        }
        return Collections.unmodifiableSet(res);
    }

    public int outDegreeOf(V vertex)
    {
        Set<E> res = outgoingEdgesOf(vertex);
        return res.size();
    }

    public Set<E> outgoingEdgesOf(V vertex)
    {
        Set<E> res = new HashSet<E>();
        if (getG1().containsVertex(vertex)) {
            res.addAll(getG1().outgoingEdgesOf(vertex));
        }
        if (getG2().containsVertex(vertex)) {
            res.addAll(getG2().outgoingEdgesOf(vertex));
        }
        return Collections.unmodifiableSet(res);
    }
}

// End DirectedGraphUnion.java
