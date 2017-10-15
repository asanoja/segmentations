/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations.evaluationgui;

import java.net.URL;
import java.util.ArrayList;



/**
 *
 * @author asanoja
 */
public abstract class Segmentation {
    protected Configuration conf;
    protected URL url;
    protected ArrayList<Block> blocks;
    protected RecordParser rp;
    
    public Segmentation(URL url,Configuration conf) {
        this.conf = conf;
        this.url = url;
        this.blocks = new ArrayList<Block>();
    }
    public abstract void load();
    
    public abstract ArrayList<Block> getBlocks();
}
