/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.web.evaluation;

/**
 *
 * @author asanoja
 */
class Edge {
    private Node start;
    private Node end;
    private double weight=0;
    
    public Edge(Node start,Node end,double weight) {
        this.start = start;
        this.end = end;
        this.weight = weight;
    }
    
    public Node getStartNode() {
        return(start);
    }
    public Node getEndNode() {
        return(end);
    }

    /**
     * @return the weight
     */
    public double getWeight() {
        return weight;
    }

    /**
     * @param weight the weight to set
     */
    public void setWeight(double weight) {
        this.weight = weight;
    }
}
