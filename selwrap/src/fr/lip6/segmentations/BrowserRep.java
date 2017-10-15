/*
# Andrés Sanoja
# UPMC - LIP6
# pagelyzer 
#
# Copyright (C) 2011, 2012, 2013, 2014 Andrés Sanoja, Université Pierre et Marie Curie -
# Laboratoire d'informatique de Paris 6 (LIP6)
#
# Authors
# Andrés Sanoja andres.sanoja@lip6.fr
# Alexis Lechervy alexis.lechervy@lip6.fr
# Zeynep Pehlivan zeynep.pehlivan@lip6.fr
# Myriam Ben Saad myriam.ben-saad@lip6.fr
# Marc Law marc.law@lip6.fr
# Carlos Sureda carlos.sureda@lip6.fr
# Jordi Creus jordi.creus@lip6.fr
# LIP6 / Université Pierre et Marie Curie

# Responsables WP
# Matthieu CORD/UPMC
# Stéphane GANÇARSKI/UPMC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Some parts of this package are adapted from the BrowserShot proyect developed by IM, France.
# https://github.com/sbarton/browser-shot-tool-mapred
 */

package fr.lip6.segmentations;

import com.opera.core.systems.OperaDriver;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.htmlunit.HtmlUnitDriver;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.remote.Augmenter;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;

/**
 *
 * @author sanojaa
 * Class encapsulating the browser representation for the job
 * This class is a adaptation from the BrowserRep class from BrowserShot_mapred proyect
*/
       public class BrowserRep {
            WebDriver driver;
            DesiredCapabilities capabilities;
            String desc;
            JavascriptExecutor js;
            Actions actions;
            private static final long MAX_WAIT_S = 45;
            
            public BrowserRep() {
                this.driver = null;
                this.capabilities = null;
                this.desc = "";
                this.js = null;
                this.actions = null;
            }
            
            public BrowserRep(WebDriver driver, DesiredCapabilities capabilities, String desc) {
                this.driver = driver;
                this.capabilities = capabilities;
                this.desc = desc;
                this.actions = new Actions(this.driver);
                if (driver instanceof JavascriptExecutor) {
                    this.js = (JavascriptExecutor)driver;
                }
            }   
            
            public Actions getActions() {
                return(this.actions);
            }
            private void setJSDriver() {
                if (this.driver instanceof JavascriptExecutor) {
                    this.js = (JavascriptExecutor)this.driver;
                }
            }
            
            public void setLocalDriver() {
                switch (this.desc) {
                    case "firefox"  : this.driver = new FirefoxDriver();break;
                    case "iexplorer": this.driver = new InternetExplorerDriver();break;
                    case "chrome"   : this.driver = new ChromeDriver();break;
                    case "opera"    : this.driver = new OperaDriver();break;
                    case "htmlunit" : this.driver = new HtmlUnitDriver();break;
                }
                setJSDriver();
                this.driver.manage().timeouts().pageLoadTimeout(MAX_WAIT_S, TimeUnit.SECONDS);
                this.driver.manage().timeouts().implicitlyWait(MAX_WAIT_S, TimeUnit.SECONDS);
                this.driver.manage().window().setSize(new org.openqa.selenium.Dimension(1024,768));
            }
            
            public void setRemoteDriver() throws MalformedURLException {
                this.driver = new RemoteWebDriver(new URL(SeleniumWrapper.seleniumUrl),capabilities);
                setJSDriver();
                this.driver = new Augmenter().augment(this.driver);
                this.driver.manage().timeouts().pageLoadTimeout(MAX_WAIT_S, TimeUnit.SECONDS);
                this.driver.manage().timeouts().implicitlyWait(MAX_WAIT_S, TimeUnit.SECONDS);
                this.driver.manage().window().setSize(new org.openqa.selenium.Dimension(1024,768));
            }
            
            public void close() {
                try {
                    this.driver.quit();
                    this.driver = null;
                    this.js = null;
                } catch (Exception e) {
                    
                }
            }
            
            public void open(String url) {
                try {
                    this.driver.get(url);
                } catch (Exception e) {
                    
                }
            }
            
            public WebElement findElement(String id) {
                return(this.driver.findElement(By.id(id)));
            }
            public String asHTML() {
                return(this.driver.getPageSource());
            }
           
        }
