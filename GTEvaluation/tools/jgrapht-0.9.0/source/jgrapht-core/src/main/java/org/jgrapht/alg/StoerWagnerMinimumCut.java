/* ==========================================
 * JGraphT : a free Java graph-theory library
 * ==========================================
 *
 * Project Info:  http://jgrapht.sourceforge.net/
 * Project Creator:  Barak Naveh (http://sourceforge.net/users/barak_naveh)
 *
 * (C) Copyright 2003-2011, by Barak Naveh and Contributors.
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
/* ----------------
 * StoerWagnerMinimumCut.java
 * ----------------
 * (C) Copyright 2011-2011, by Robby McKilliam and Contributors.
 *
 * Original Author:  Robby McKilliam
 * Contributor(s):   Ernst de Ridder
 *
 * $Id: StoerWagnerMinimumCut.java $
 *
 * Changes
 * -------
 *
 */
package org.jgrapht.alg;

import java.util.*;

import org.jgrapht.*;
import org.jgrapht.graph.*;
import org.jgrapht.util.*;


/**
 * Implements the <a href="http://dl.acm.org/citation.cfm?id=263872">Stoer and
 * Wagner minimum cut algorithm</a>. Deterministically computes the minimum cut
 * in O(|V||E| + |V|log|V|) time. This implementation uses Java's PriorityQueue
 * and requires O(|V||E|log|E|) time. M. Stoer and F. Wagner, "A Simple Min-Cut
 * Algorithm", Journal of the ACM, volume 44, number 4. pp 585-591, 1997.
 *
 * @author Robby McKilliam, Ernst de Ridder
 */
public class StoerWagnerMinimumCut<V, E>
{
    

    final WeightedGraph<Set<V>, DefaultWeightedEdge> workingGraph;

    protected double bestCutWeight = Double.POSITIVE_INFINITY;
    protected Set<V> bestCut;

    

    /**
     * Will compute the minimum cut in graph.
     *
     * @param graph graph over which to run algorithm
     *
     * @throws IllegalArgumentException if a negative weight edge is found
     * @throws IllegalArgumentException if graph has less than 2 vertices
     */
    public StoerWagnerMinimumCut(UndirectedGraph<V, E> graph)
    {
        if (graph.vertexSet().size() < 2) {
            throw new IllegalArgumentException(
                "Graph has less than 2 vertices");
        }

        //get a version of this graph where each vertex is wrapped with a list
        workingGraph =
            new SimpleWeightedGraph<Set<V>, DefaultWeightedEdge>(
                DefaultWeightedEdge.class);
        Map<V, Set<V>> vertexMap = new HashMap<V, Set<V>>();
        for (V v : graph.vertexSet()) {
            Set<V> list = new HashSet<V>();
            list.add(v);
            vertexMap.put(v, list);
            workingGraph.addVertex(list);
        }
        for (E e : graph.edgeSet()) {
            if (graph.getEdgeWeight(e) < 0.0) {
                throw new IllegalArgumentException(
                    "Negative edge weights not allowed");
            }

            V s = graph.getEdgeSource(e);
            Set<V> sNew = vertexMap.get(s);
            V t = graph.getEdgeTarget(e);
            Set<V> tNew = vertexMap.get(t);

            // For multigraphs, we sum the edge weights (either all are
            // contained in a cut, or none)
            DefaultWeightedEdge eNew = workingGraph.getEdge(sNew, tNew);
            if (eNew == null) {
                eNew = workingGraph.addEdge(sNew, tNew);
                workingGraph.setEdgeWeight(eNew, graph.getEdgeWeight(e));
            } else {
                workingGraph.setEdgeWeight(
                    eNew,
                    workingGraph.getEdgeWeight(eNew) + graph.getEdgeWeight(e));
            }
        }

        //arbitrary vertex used to seed the algorithm.
        Set<V> a = workingGraph.vertexSet().iterator().next();

        while (workingGraph.vertexSet().size() > 1) {
            minimumCutPhase(a);
        }
    }

    

    /**
     * Implements the MinimumCutPhase function of Stoer and Wagner
     */
    protected void minimumCutPhase(Set<V> a)
    {
        // The last and before last vertices added to A.
        Set<V> last = a, beforelast = null;

        // queue contains vertices not in A ordered by max weight of edges to A.
        PriorityQueue<VertexAndWeight> queue =
            new PriorityQueue<VertexAndWeight>();

        // Maps vertices to elements of queue
        Map<Set<V>, VertexAndWeight> dmap =
            new HashMap<Set<V>, VertexAndWeight>();

        // Initialize queue
        for (Set<V> v : workingGraph.vertexSet()) {
            if (v == a) {
                continue;
            }
            DefaultWeightedEdge e = workingGraph.getEdge(v, a);
            Double w = (e == null) ? 0.0 : workingGraph.getEdgeWeight(e);
            VertexAndWeight vandw = new VertexAndWeight(v, w, e != null);
            queue.add(vandw);
            dmap.put(v, vandw);
        }

        // Now iteratively update the queue to get the required vertex ordering

        while (!queue.isEmpty()) {
            Set<V> v = queue.poll().vertex;
            dmap.remove(v);

            beforelast = last;
            last = v;

            for (DefaultWeightedEdge e : workingGraph.edgesOf(v)) {
                Set<V> vc = Graphs.getOppositeVertex(workingGraph, e, v);
                VertexAndWeight vcandw = dmap.get(vc);
                if (vcandw != null) {
                    queue.remove(vcandw); //this is O(logn) but could be O(1)?
                    vcandw.active = true;
                    vcandw.weight += workingGraph.getEdgeWeight(e);
                    queue.add(vcandw); //this is O(logn) but could be O(1)?
                }
            }
        }

        // Update the best cut
        double w = vertexWeight(last);
        if (w < bestCutWeight) {
            bestCutWeight = w;
            bestCut = last;
        }

        //merge the last added vertices
        mergeVertices(beforelast, last);
    }

    /**
     * Return the weight of the minimum cut
     */
    public double minCutWeight()
    {
        return bestCutWeight;
    }

    /**
     * Return a set of vertices on one side of the cut
     */
    public Set<V> minCut()
    {
        return bestCut;
    }

    /**
     * Merges vertex t into vertex s, summing the weights as required. Returns
     * the merged vertex and the sum of its weights
     */
    protected VertexAndWeight mergeVertices(Set<V> s, Set<V> t)
    {
        //construct the new combinedvertex
        Set<V> set = new HashSet<V>();
        set.addAll(s);
        set.addAll(t);
        workingGraph.addVertex(set);

        //add edges and weights to the combined vertex
        double wsum = 0.0;
        for (Set<V> v : workingGraph.vertexSet()) {
            if ((s != v) && (t != v)) {
                double neww = 0.0;
                DefaultWeightedEdge etv = workingGraph.getEdge(t, v);
                DefaultWeightedEdge esv = workingGraph.getEdge(s, v);
                if (etv != null) {
                    neww += workingGraph.getEdgeWeight(etv);
                }
                if (esv != null) {
                    neww += workingGraph.getEdgeWeight(esv);
                }
                if ((etv != null) || (esv != null)) {
                    wsum += neww;
                    workingGraph.setEdgeWeight(
                        workingGraph.addEdge(set, v),
                        neww);
                }
            }
        }

        //remove original vertices
        workingGraph.removeVertex(t);
        workingGraph.removeVertex(s);

        return new VertexAndWeight(set, wsum, false);
    }

    /**
     * Compute the sum of the weights entering a vertex
     */
    public double vertexWeight(Set<V> v)
    {
        double wsum = 0.0;
        for (DefaultWeightedEdge e : workingGraph.edgesOf(v)) {
            wsum += workingGraph.getEdgeWeight(e);
        }
        return wsum;
    }

    

    /**
     * Class for weighted vertices
     */
    protected class VertexAndWeight
        implements Comparable<VertexAndWeight>
    {
        public Set<V> vertex;
        public Double weight;
        public boolean active; // active == neighbour in A

        public VertexAndWeight(Set<V> v, double w, boolean active)
        {
            this.vertex = v;
            this.weight = w;
            this.active = active;
        }

        /**
         * compareTo that sorts in reverse order because we need extract-max and
         * queue provides extract-min.
         */
        @Override public int compareTo(VertexAndWeight that)
        {
            if (this.active && that.active) {
                return -Double.compare(weight, that.weight);
            }
            if (this.active && !that.active) {
                return -1;
            }
            if (!this.active && that.active) {
                return +1;
            }

            // both inactive
            return 0;
        }

        @Override public String toString()
        {
            return "(" + vertex + ", " + weight + ")";
        }
    }
}

// End StoerWagnerMinimumCut.java
