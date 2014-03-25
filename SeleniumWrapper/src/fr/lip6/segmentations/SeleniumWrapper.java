/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package fr.lip6.segmentations;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.util.Arrays;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.Platform;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.remote.DesiredCapabilities;

/**
 *
 * @author sanojaa
 */
public abstract class SeleniumWrapper {
    
    private BrowserRep driver = null;
    
    private String baseHostFrag = "";
    public static String seleniumUrl = "http://127.0.0.1:8015/wd/hub";
    
    private int injectCount = 0;
    private Object buffer = null;
    protected boolean local = true;
    protected String category = "none";
    private ServerLyzer server = new ServerLyzer();
    
    public SeleniumWrapper() {}
    
    public void basehost(String host) {
        this.baseHostFrag = host;
        System.out.println(host);
    }
    
    public void open(String br) throws MalformedURLException, Exception {
        this.driver = new BrowserRep();
        setup(br);
        if (getIsLocalDriver()) {
            this.driver.setLocalDriver();
        } else {
            this.driver.setRemoteDriver();
        }
        this.server.start(8030); //ojo sacar del basehost
        System.out.println("Opened");
    }
    
    public void close() {
        if (this.driver != null) {
            this.driver.close();
        }
        if (this.server!=null) {
            this.server.stop();
        }
        System.out.println("Closed");
    }
    
    public void navigate(String url) {
        this.driver.open(url);
        System.out.println("GOTO "+url);
    }
    
    public void hold(long ms) throws InterruptedException {
        System.out.println("Wait " + (ms*1000));
        Thread.sleep(ms*1000);
       
    }
    
    public void execute(String code) throws org.openqa.selenium.WebDriverException {
        this.buffer = this.driver.js.executeScript(code);
        System.out.println("JS code executed");
    }

    public void inject(String ref) {
        String src="";
        String loadJs = "";
        this.injectCount++;
        if (this.baseHostFrag == "") {
            src = ref;
        } else {
            if (ref.startsWith("http://")) {
                src = ref;
            } else {
                src = this.baseHostFrag +"/" + ref;
            }
        }
        loadJs = "function func_dump"+this.injectCount+"() {";
        loadJs +="var script = document.createElement('script');";
        loadJs +="script.type = \"text/javascript\";";
        loadJs +="script.setAttribute('id','bfinject"+this.injectCount+"');";
        loadJs +="script.setAttribute('src','"+src+"');";
        loadJs +="document.getElementsByTagName('head')[0].appendChild(script);";
        loadJs +="}";
        loadJs +="var callback = arguments[arguments.length - 1];";
        loadJs +="callback(func_dump"+this.injectCount+"());     ";
        
        this.driver.js.executeAsyncScript(loadJs);
        System.out.println(src);
    }
    public void saveTo(String path) throws IOException {
        if (this.buffer!=null)  {
            FileWriter fstream = new FileWriter(path);
            BufferedWriter out = new BufferedWriter(fstream);
            out.write(this.buffer.toString());
            out.close();
            System.out.println("Saved to "+path);
        } else {
            System.out.println("Buffer empty. Not saving");
        }
    }
    public void dumpContent() {
        this.buffer = this.driver.asHTML();
    }
    public void placeIn(String id) {
        if (this.buffer!=null)  {
            String s = ((String) this.buffer).replace("\n", "\\n").replace(",none,",","+this.category+",");
            execute("return document.getElementById('"+id+"').value=\""+s+"\"");
            System.out.println("Buffer placed in "+id);
        }else {
            System.out.println("Buffer empty. Not placing in");
        }
    }
    public String localUrl(String fragment) {
        String s = this.baseHostFrag;
        if (s.endsWith("/")) {
            s = s.substring(0, s.length() - 1);
        }
        return(s + "/" + fragment);
    }
    public void submit(String id) {
        this.driver.findElement(id).submit();
       System.out.println("Submited "+id);
    }
    
    public void jar(String jarBaseName,String args) throws IOException {
        Process proc;
        String cmd ="cd lib;java -jar "+jarBaseName+".jar "+args;
        proc = Runtime.getRuntime().exec(cmd);
        InputStream in = proc.getInputStream();
        InputStream err = proc.getErrorStream();
        int data = in.read();
        while (data != -1) {
            System.out.println(data);
            data = in.read();
        }
        in.close();
        int error = err.read();
        while (error != -1) {
            System.out.println(error);
            error = err.read();
        }
        err.close();
        System.out.println("Executed "+cmd);
    }
    
//    protected abstract void run(String url);
    
    /* general methods*/
    
    public void setIsLocalDriver(boolean val)  {
        this.local = val;
    }
    public boolean getIsLocalDriver() {
        return(this.local);
    }
    
    public Object getBuffer() {
        return(this.buffer);
    }
    public void setBuffer(Object object) {
        this.buffer = object;
    }
    protected void setup(String browser) {     
            System.out.println("Setting up browser: "+browser);
            DesiredCapabilities capability = null;
            if  (browser.equals("firefox")) {
                capability = DesiredCapabilities.firefox();
            }
            else if (browser.equals("opera")) {
                capability = DesiredCapabilities.opera();
            }
            else if (browser.equals("chrome")) {
                capability = DesiredCapabilities.chrome();
                capability.setCapability("chrome.switches", Arrays.asList("--disable-logging"));
            }else {
                throw new RuntimeException("Browser "+browser+ " not recognized.");
            }

            capability.setPlatform(Platform.LINUX);                
            this.driver.desc = browser;
            this.driver.capabilities = capability;
        }
}
