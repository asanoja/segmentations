/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations.evaluationgui;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

/**
 *
 * @author sanojaa
 */
public class InputURLParser {
    
    private ArrayList<URL> urls;
    private Configuration conf;
    
    public InputURLParser(Configuration conf) {
        this.conf = conf;
        this.urls = new ArrayList<URL>();
        downloadFrom("http://www-poleia.lip6.fr/~sanojaa/BOM/urllist_plain.php");
    }
    
    public ArrayList<URL> getList() {
        return(this.urls);
    }
    
    private void downloadFrom(String baseDataUrl) {
        String data ="";
        
        DefaultHttpClient httpclient = new DefaultHttpClient();
        String dataUrl = baseDataUrl + "?collection_id="+conf.getCollection()+"&category="+conf.getCategory();
        HttpGet httpGet = new HttpGet(dataUrl);
        try {
          HttpResponse response = httpclient.execute(httpGet);
          HttpEntity entity = response.getEntity();
          if (entity != null) {
              data = EntityUtils.toString(entity);
              String[] rows = data.split("\n");
              for (String row : rows) {
                  URL url = new URL(row);
                  this.urls.add(url);
//                  System.out.println(url.toString());
              }
          }
        } catch (ClientProtocolException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
