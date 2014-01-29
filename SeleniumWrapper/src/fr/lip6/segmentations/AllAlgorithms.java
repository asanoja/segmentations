/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations;

import java.net.MalformedURLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author sanojaa
 */
public class AllAlgorithms extends SeleniumWrapper {
    
    public void run(String browser,String url,String pac) {
        try {
            String collectUrl = "http://www-poleia.lip6.fr/~sanojaa/BOM/add.php";
            basehost("http://localhost:8030");
            open(browser);
            
            // GET BOM RECORD
            navigate(url);
            inject("jquery-min.js");
            inject("bomlib.js");
            inject("rectlib.js");
            inject("polyk.js");
            inject("md5.js");
            inject("sniff.js");
            execute("startSegmentation(window,"+pac+",50,true);return getRecord(page)");
            saveTo("bom.rec");
            navigate(collectUrl);
            placeIn("record");
            submit("record");
            
            // GET BLOCKFUSION
            navigate(url);
            inject("jquery-min.js");
            inject("rectlib.js");
            
            String[] args = {url,System.getProperty("user.dir")+"/www/bftmp.js"};
            de.l3s.boilerpipe.demo.HTMLBlocksDemo.main(args);
            
            inject("bftmp.js");
            inject("bfanalyzer.js");
            
            execute("return bfprocess(0.3)");
            saveTo("bf.rec");
            
            setBuffer(new BFProcess().parse(getBuffer(),browser,url,pac));
            
            navigate(collectUrl);
            placeIn("record");
            submit("record");
            
            // GET jVIPS
            
            String[] argss = {url};
            org.fit.vips.VipsTester.main(argss);
            String rec = org.fit.vips.VipsTester.Salida;
            setBuffer(org.fit.vips.VipsTester.Salida);
            
            navigate(collectUrl);
            placeIn("record");
            submit("record");
            hold(5000);
            
        } catch (MalformedURLException ex) {
            Logger.getLogger(AllAlgorithms.class.getName()).log(Level.SEVERE, null, ex);
        } catch (Exception ex) {
            Logger.getLogger(AllAlgorithms.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            close();
        }
        
    }
    
    public static void main(String args[]) {
        (new AllAlgorithms()).run("chrome","http://www-poleia.lip6.fr/~sanojaa/dummy.html","0.3");
    }
}
