package fr.lip6.segmentations.evaluationgui;

import java.io.IOException;
import java.net.URL;
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
public class Measure {

    private int tc;
    private int co;
    private int cu;
    private int cm;
    private int cf;
    private float score1;
    private float score2;
    private Configuration conf1;
    private Configuration conf2;
    private Parameters params;
    private URL url;
    private int gtb;
    private int stb;

    public Measure(URL url,int tc, int co, int cu, int cm, int cf, int gtb,int stb, Configuration conf1,Configuration conf2,Parameters params) {
        this.tc = tc;
        this.co = co;
        this.cu = cu;
        this.cm = cm;
        this.cf = cf;
        this.score1 = tc / (1 + co + cm);
        this.score2 = tc / (1 + cu + cf);
        this.conf1 = conf1;
        this.conf2 = conf2;
        this.params = params;
        this.url = url;
        this.gtb = gtb;
        this.stb = stb;
    }
    public String toString() {
        return("URL:"+this.url+" Tc:"+tc+" Co:"+co+" Cu:"+cu+" Cm:"+cm+" Cf:"+cf+" Gtb:"+gtb);
    }
    public void sendTo(String baseDataUrl) {
        String data ="";
        
        DefaultHttpClient httpclient = new DefaultHttpClient();
        String dataUrl = baseDataUrl + "?url="+url.toString()+"&category="+conf1.getCategory()+"&tc="+tc+"&co="+co+"&cm="+cm+"&cu="+cu+"&cf="+cf+"&tt="+params.getTt()+"&tr="+params.getTr()+"&algorithm1="+conf1.getAlgoData()+"&algorithm2="+conf2.getAlgoData()+"&browser1="+conf1.getBrowser()+"&browser2="+conf2.getBrowser()+"&gtb="+gtb+"&stb="+stb+"&collection_id="+conf1.getCollection()+"&score1="+score1+"&score2="+score2;
        HttpGet httpGet = new HttpGet(dataUrl);
        try {
          HttpResponse response = httpclient.execute(httpGet);
          HttpEntity entity = response.getEntity();
          if (entity == null) {
              System.out.println("Error sending metrics :(");
          }
        } catch (ClientProtocolException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
