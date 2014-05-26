/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package crawlerwbm;

import fr.lip6.segmentations.BrowserRep;
import fr.lip6.segmentations.SeleniumWrapper;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.openqa.selenium.WebElement;


/**
 *
 * @author sanojaa
 */
public class CrawlerWBM extends SeleniumWrapper {
//    private BrowserRep driver;

     public void run(String category,String url,String browser) throws Exception {
         open(browser);
         navigate(url);
         WebElement query = this.getBrowserRep().findElement(url);
     }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        
        CrawlerWBM instance = new CrawlerWBM();
         try {
             instance.run("none","https://archive.org/web/web.php","firefox");
         } catch (Exception ex) {
             Logger.getLogger(CrawlerWBM.class.getName()).log(Level.SEVERE, null, ex);
         }
        
    }
    
}
