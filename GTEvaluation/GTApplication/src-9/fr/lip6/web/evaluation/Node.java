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
class Node {
    private Block b;
    private int out=0;
    private int in=0;
    
    public Node(Block b) {
        this.b = b;
    }
    public Block getBlock() {
        return(this.b);
    }
    public void incOut(){
        out++;
    }
    public void incIn(){
        in++;
    }

    public int getOut() {
        return out;
    }

    public int getIn() {
        return in;
    }
}
