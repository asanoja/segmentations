/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations.evaluationgui;

import java.net.URL;

/**
 *
 * @author sanojaa
 */
class Parameters {
    private int tt;
    private float tr;
    
    public Parameters(int tt,float tr) {
        this.tt = tt;
        this.tr = tr;
    }

    /**
     * @return the tt
     */
    public int getTt() {
        return tt;
    }

    /**
     * @param tt the tt to set
     */
    public void setTt(int tt) {
        this.tt = tt;
    }

    /**
     * @return the tr
     */
    public float getTr() {
        return tr;
    }

    /**
     * @param tr the tr to set
     */
    public void setTr(float tr) {
        this.tr = tr;
    }

}
