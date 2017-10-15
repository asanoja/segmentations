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
import org.dom4j.Document;

/**
 *
 * @author asanoja
 */
public class RecordParser {
    private Configuration conf;
    private URL url;
    private ArrayList<Record> records;
    
    public RecordParser(URL url,Configuration conf) {
        this.conf = conf;
        this.url = url;
        this.records = new ArrayList<Record>();
    }
    public ArrayList<Record> parse() {
        downloadFrom("http://www-poleia.lip6.fr/~sanojaa/BOM/record.php");
        return(this.records);
        
    }
    private void downloadFrom(String baseDataUrl) {
        String data ="";
        
        DefaultHttpClient httpclient = new DefaultHttpClient();
        String dataUrl = baseDataUrl + "?source="+conf.getAlgo().toUpperCase()+"data&filter="+url.toString()+"&browser="+conf.getBrowser()+"&collection_id="+conf.getCollection()+"&category="+conf.getCategory();
        HttpGet httpGet = new HttpGet(dataUrl);
        try {
          HttpResponse response = httpclient.execute(httpGet);
          HttpEntity entity = response.getEntity();
          if (entity != null) {
              data = EntityUtils.toString(entity);
              String[] rows = data.split("\n");
              for (String row : rows) {
                  Record rec = new Record(row);
                  this.records.add(rec);
                  //System.out.println(rec.toString());
              }
          }
        } catch (ClientProtocolException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
