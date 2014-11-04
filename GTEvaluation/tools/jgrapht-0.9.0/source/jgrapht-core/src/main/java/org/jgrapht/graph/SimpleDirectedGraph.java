/* ==========================================
 * JGraphT : a free Java graph-theory library
 * ==========================================
 *
 * Project Info:  http://jgrapht.sourceforge.net/
 * Project Creator:  Barak Naveh (http://sourceforge.net/users/barak_naveh)
 *
 * (C) Copyright 2003-2008, by Barak Naveh and Contributors.
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
/* ------------------------
 * SimpleDirectedGraph.java
 * ------------------------
 * (C) Copyright 2003-2008, by Barak Naveh and Contributors.
 *
 * Original Author:  Barak Naveh
 * Contributor(s):   Christian Hammer
 *
 * $Id$
 *
 * Changes
 * -------
 * 05-Aug-2003 : Initial revision (BN);
 * 06-Aug-2005 : Made generic (CH);
 * 28-May-2006 : Moved connectivity info from edge to graph (JVS);
 *
 */
package org.jgrapht.graph;

import org.jgrapht.*;


/**
 * A simple directed graph. A simple directed graph is a directed graph in which
 * neither multiple edges between any two vertices nor loops are permitted.
 */
public class SimpleDirectedGraph<V, E>
    extends AbstractBaseGraph<V, E>
    implements DirectedGraph<V, E>
{
    

    private static final long serialVersionUID = 4049358608472879671L;

    

    /**
     * Creates a new simple directed graph.
     *
     * @param edgeClass class on which to base factory for edges
     */
    public SimpleDirectedGraph(Class<? extends E> edgeClass)
    {
        this(new ClassBasedEdgeFactory<V, E>(edgeClass));
    }

    /**
     * Creates a new simple directed graph with the specified edge factory.
     *
     * @param ef the edge factory of the new graph.
     */
    public SimpleDirectedGraph(EdgeFactory<V, E> ef)
    {
        super(ef, false, false);
    }
}

// End SimpleDirectedGraph.java
