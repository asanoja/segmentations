/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations;

import com.google.common.collect.Maps;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author sanojaa
 */
public class BFProcess {
    private Document document;
    
    public String parse(Object buffer,String browser,String url,String gran) {
        ArrayList refs = (ArrayList) buffer;
        ArrayList docpart = (ArrayList) refs.get(0);
        ArrayList<ArrayList> blockspart = (ArrayList) refs.get(1);
        String sal = "";
        document = new Document();
        document.parse(docpart);
//        System.out.println(blockspart.get(0));
        
        for (ArrayList bref : blockspart) {
            if (bref != null) {
                if (bref.get(1) != null) {
                    if (!bref.get(1).equals("DISCARDED") ) {
                        Block block = new Block();
                        block.parse(bref);
                        sal += "BF,"+browser+",none,"+url+","+document.toRecord()+","+gran+","+block.toRecord()+"\n";
                        //System.out.println(sal);
                    }
                }
            }
        }
        return(sal);
    }
}
