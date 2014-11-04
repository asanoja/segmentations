/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.web.evaluation;

import java.awt.PopupMenu;
import java.util.ArrayList;

/**
 *
 * @author asanoja
 */
public class BCG extends PopupMenu {
    private Segmentation g;
    private Segmentation p;
    private ArrayList<Node> nodesG;
    private ArrayList<Node> nodesP;
    private ArrayList<Edge> edges;
    
    
    
    public BCG(Segmentation sg, Segmentation sp) {
        this.nodesG = new ArrayList();
        this.nodesP = new ArrayList();
        this.edges = new ArrayList();
        for (Block b : sg.getBlocks()) {
            this.addNodeG(b);
        }
        for (Block b : sp.getBlocks()) {
            this.addNodeP(b);
        }
//        this.edges.add(new Edge(nodesG.get(0),nodesP.get(0)));
//        this.edges.add(new Edge(nodesP.get(0),nodesG.get(1)));
    }
    
    public final void addNodeG(Block block) {
        this.nodesG.add(new Node(block));
    }
    public final void addNodeP(Block block) {
        this.nodesP.add(new Node(block));
    }
    public final void addEdge(Node ni,Node nj) {
        ni.incOut();
        nj.incIn();
        this.edges.add(new Edge(ni,nj,computeWeight(ni, nj)));
    }

    public boolean exist(Edge e) {
        for (Edge d : this.edges) {
            if ( (d.getStartNode().getBlock().getId().equals(e.getStartNode().getBlock().getId())) && (d.getEndNode().getBlock().getId().equals(e.getEndNode().getBlock().getId())) ) {
                return(true);
            }
        }
        return(false);
    }
    
    public ArrayList<Node> getNodesG() {
        return(nodesG);
    }
    
    public ArrayList<Node> getNodesP() {
        return(nodesP);
    }
    
    public ArrayList<Edge> getEdges() {
        return(edges);
    }
    public Node findNodeGById(String id) {
        for (Node n : nodesG) {
            if (n.getBlock().getId().equals(id)) {
                return(n);
            }
        }
        return(null);
    }
    public double computeWeight(Node ni,Node nj) {
        return (double) Math.min(ni.getBlock().weight(),nj.getBlock().weight()) / Math.max(ni.getBlock().weight(),nj.getBlock().weight());
    }
    
	
//	this.nodeExistG = function(n) {
//		for (var i=0;i<this.nodesG.length;i++) {
//			if (this.nodesG[i].id == n.id) {
//				return(true);
//			}
//		}
//		return(false);
//	}
//	this.nodeExistP = function(n) {
//		for (var i=0;i<this.nodesP.length;i++) {
//			if (this.nodesP[i].id == n.id) {
//				return(true);
//			}
//		}
//		return(false);
//	}
	
//	this.addArcGP = function(g,p,weight) {
//		if (!this.nodeExistG(g)) this.nodesG.push(g);
//		if (!this.nodeExistP(p)) this.nodesP.push(p);
//		var v = new Arc();
//		v.start = g;
//		v.end = p;
//		v.type = "gp";
//		v.weight = weight;
//		if (!this.exist(v)) this.arcs.push(v);
//	}
//	this.addArcPG = function(p,g,weight) {
//		if (!this.nodeExistG(g)) this.nodesG.push(g);
//		if (!this.nodeExistP(p)) this.nodesP.push(p);
//		var v = new Arc();
//		v.start = p;
//		v.end = g;
//		v.type = "pg";
//		v.weight = weight;
//		if (!this.exist(v)) this.arcs.push(v);
//	}
//	this.countFrom = function(block) {
//		var cont=0;
//		for (var i=0;i<this.arcs.length;i++) {
//			if (this.arcs[i].start.id == block.id) cont++;
//		}
//		return(cont);
//	}
//	this.countTo = function(block) {
//		var cont=0;
//		for (var i=0;i<this.arcs.length;i++) {
//			if (this.arcs[i].end.id == block.id) cont++;
//		}
//		return(cont);
//	}
//	this.findNodesByStart = function(block) {
//		var nodes=[];
//		for (var i=0;i<this.arcs.length;i++) {
//			if (this.arcs[i].start.id == block.id) nodes.push(this.arcs[i]);
//		}
//		return(nodes);
//	}
//	this.findNodesByEnd = function(block) {
//		var nodes=[];
//		for (var i=0;i<this.arcs.length;i++) {
//			if (this.arcs[i].end.id == block.id) nodes.push(this.arcs[i]);
//		}
//		return(nodes);
//	
}
