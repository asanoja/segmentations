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
/* -----------------
 * EdgeTopologyCompare.java
 * -----------------
 * (C) Copyright 2005-2008, by Assaf Lehr and Contributors.
 *
 * Original Author:  Assaf Lehr
 * Contributor(s):   -
 *
 * $Id$
 *
 * Changes
 * -------
 */
package org.jgrapht.experimental.isomorphism;

import org.jgrapht.*;


/**
 * @author Assaf
 * @since Aug 6, 2005
 */
public class EdgeTopologyCompare
{
    //~ Methods ----------------------------------------------------------------

    /**
     * Compare topology of the two graphs. It does not compare the contents of
     * the vertexes/edges, but only the relationships between them.
     *
     * @param g1
     * @param g2
     */
    @SuppressWarnings("unchecked")
    public static boolean compare(Graph g1, Graph g2)
    {
        boolean result = false;
        GraphOrdering lg1 = new GraphOrdering(g1);
        GraphOrdering lg2 = new GraphOrdering(g2);
        result = lg1.equalsByEdgeOrder(lg2);

        return result;
    }
}

// End EdgeTopologyCompare.java
