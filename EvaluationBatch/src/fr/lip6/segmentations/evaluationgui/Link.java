/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations.evaluationgui;

/**
 *
 * @author sanojaa
 */
public class Link {
   private int method;
   private float value;
   private Block b1,b2;
   
   public Link(Block b1,Block b2) {
       this.b1 = b1;
       this.b2 = b2;
   }
   public float compute(int method) {
       float value=0;
        if (method == Evaluation.EQUALS) {
            value =  b1.weight();
        } else if (method == Evaluation.CONTAINED) {
            if (b1.weight() != 0) {
                value =  Math.min(b1.weight(),b2.weight()) / b1.weight();
            } else {
                value =  0;
            }
        }
        return(value);
    }
   public boolean significative(float tr,int method) {
//       return(compute(method)>=tr);
       return(true);
   }
   public Link fix(int method) {
       this.method = method;
       this.value = compute(method);
       return(this);
   }
   public String toString() {
       return(Float.toString(this.value));
   }
}
