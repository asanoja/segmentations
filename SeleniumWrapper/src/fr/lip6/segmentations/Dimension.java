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
public class Dimension {
    
    public double x=0;
    public double y=0;
    public double w=0;
    public double h=0;
    
    public Dimension(ArrayList arr) {
        this.x = Double.parseDouble(arr.get(0).toString());
        this.y = Double.parseDouble(arr.get(1).toString());
        this.w = Double.parseDouble(arr.get(2).toString());
        this.h = Double.parseDouble(arr.get(3).toString());
    }
}
