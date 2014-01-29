/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations;

import java.util.ArrayList;



/**
 *
 * @author sanojaa
 */
public class Document {
    private long w = 0;
    private long h = 0;
    
    public void parse(Object obj) {
        ArrayList harr = (ArrayList) obj;
        this.w = Long.parseLong(harr.get(0).toString());
        this.h = Long.parseLong(harr.get(1).toString());
    }
    public String toRecord() {
        return(this.w + "," + this.h);
    }
}
