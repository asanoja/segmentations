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
 * @author sanojaa
 */
public class GroundTruthSegmentation extends Segmentation {

    public GroundTruthSegmentation(URL url,Configuration conf) {
        super(url,conf);
    }
    public void load() {
        this.rp = new RecordParser(url,conf);
        for (Record rec : this.rp.parse()) {
            Block b = new GroundTruthBlock(rec);
            this.blocks.add(b);
        }
    }
    public ArrayList<Block> getBlocks() {
        return(this.blocks);
    }
}
