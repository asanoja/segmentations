/*
* $Id: trackingTags_v1.1.js 132120 2013-09-23 19:53:12Z leonardo.meirelles $
*/

//  CONFIGURE HOST BASED ON ENVIRONMENT
var NYTD = NYTD || {};
NYTD.Analytics = NYTD.Analytics || {};
NYTD.Analytics.JSFileLoaded = NYTD.Analytics.JSFileLoaded || {};


if ( !NYTD.Analytics.JSFileLoaded['trackingTags_v1.1.js'] ) {

/* BEGIN ANALYTICS TRACKING */

    NYTD.Analytics.JSFileLoaded['trackingTags_v1.1.js'] = 1;

NYTD.Hosts = NYTD.Hosts ||  (function(){
  var host, scripts = document.getElementsByTagName("script");

  for (var i = 0, script; script = scripts[i]; i++) {
    host = script.src &&
/^(.+\.nytimes.com)\/js\/app\/analytics\/trackingTags_v1\.1\.js/.test(script.src) ? RegExp.$1 :'';
    if (host) { break };
  };

  return {
    imageHost: host,
    jsHost: host,
    cssHost: host
  }
})();


// START WEBTRENDS JS TAG
var gtrackevents=false;
var gdcsid="dcsym57yw10000s1s8g0boozt_9t1x";
var gfpcdom=".nytimes.com";
var gdomain="wt.o.nytimes.com";
var js_host = NYTD.Hosts.jsHost + "/js/app/analytics/";

var includeJsFile = function (incFilename, async) {

    var incFileJS = document.createElement("script");
    incFileJS.setAttribute("type", "text/javascript");
    incFileJS.setAttribute("src", incFilename);
    if (async === true) {
        incFileJS.async = true;
    }
    document.getElementsByTagName("head").item(0).appendChild(incFileJS);

}

// Include WebTrends wtid.js
var wt_initObj = { enabled:true, fpc:"WT_FPC", domain:gdomain, dcsid:gdcsid };
if (wt_initObj.enabled&&(document.cookie.indexOf(wt_initObj.fpc+"=")==-1)&&(document.cookie.indexOf("WTLOPTOUT=")==-1)){
var wtid_js_host="http"+(window.location.protocol.indexOf('https:')==0?'s':'')+"://"+wt_initObj.domain+"/"+wt_initObj.dcsid+"/";
includeJsFile(wtid_js_host+'wtid.js');
}

//includeJsFile(js_host+'controller_v1.1.js');
var _missingController = true; // do not remove - bx-853
// END WEBTRENDS JS TAG

// AudienceScience block
// Set data for AudienceScience
var _missingAudienceScience = true; // do not remove - bx-853
/*
(function () {
    var getMetaTag = function(tagName) {
        var metaTags = document.getElementsByTagName("meta");
        for (var i in metaTags) { 
            if (metaTags[i].name == tagName) {
                return metaTags[i].content;
            }
        }
      return "";
    }

    var addCategory = function(category, valueToAppend) {
        if (valueToAppend != "") {
            return category + " > " + valueToAppend;
        } else {
            return category;
        }
    }

    window.DM_prepClient = function(csid, client) {
        if ("H07707" == csid) {
            var contentGroup = getMetaTag("WT.cg_n");
            if (contentGroup != "Homepage") {
                var catValue = "NYTimesglobal";
                catValue = addCategory(catValue, contentGroup);
                catValue = addCategory(catValue, getMetaTag("WT.cg_s"));
                client.DM_cat(catValue);    
            }
        } // if H07707     
    }

    // AudienceScience script tag 
    includeJsFile('http://js.revsci.net/gateway/gw.js?csid=H07707&auto=t');
}());
*/
// End AudienceScience block

// Duped in common.js
(function(){
  if (NYTD.require) {
    return;
  }
  
  var windowLoaded = false;
  var document_scripts;
  
  if (window.addEventListener) {
    window.addEventListener ("load", function(){ windowLoaded = true }, false);
  } else if (window.attachEvent) {
    window.attachEvent ("onload", function(){ windowLoaded = true });
  }
  
  function scriptLoaded(src) {
    document_scripts = document_scripts || {};
    
    if (document_scripts[src]) { return true; }
    else {
      var script_tags= document.getElementsByTagName("script");
      for (var i = 0, script; script = script_tags[i]; i++) {
        if(script.src) { document_scripts[script.src] = 1; }
      };
      if (document_scripts[src]) { return true; }
      else { return false; }
    }
    
  }

  NYTD.require = function(file, callback) {
    
    if (windowLoaded) { throw('Cannot require file, document is already loaded'); }  

    // If matches root relative url (single slash, not protocol-agnostic double slash)
    var url = /^\/[^\/]/.test(file) ?  NYTD.Hosts.jsHost + file : file;
    var force = arguments[arguments.length - 1] === true;
    var needsCallbackScriptTag;
    
    if (force || !scriptLoaded(url)) { 
      document.write('<script src="' + url + '" type="text/javascript" charset="utf-8" onerror="throw(\'NYTD.require: An error occured: \' + this.src)"><\/script>');
      document_scripts[url] = 1;
      needsCallbackScriptTag = true;
    }

    if (typeof callback == 'function') {

      if (document.addEventListener && !navigator.userAgent.match(/MSIE/)) {
        if (needsCallbackScriptTag) { 
          document.write('<script type="text/javascript" charset="utf-8">(' + callback.toString() + ')();<\/script>');
        }
        else {
          window.setTimeout(function(){
            callback()
          }, 0)
        }
      }
      else {
        NYTD.require.callbacks = NYTD.require.callbacks || [];
        NYTD.require.callbacks.push(callback);
        NYTD.require.callbacks.count = (++NYTD.require.callbacks.count) || 0;
        document.write("<script id=__onAfterRequire" + NYTD.require.callbacks.count + " src=//:><\/script>");
        document.getElementById("__onAfterRequire" + NYTD.require.callbacks.count).onreadystatechange = function() {
          if (this.readyState == "complete") {
            this.onreadystatechange = null;
            (NYTD.require.callbacks.pop())();
            this.parentNode.removeChild(this);
          }
        };
      }

    }

  };
})();

// comscore tagging
(function () {
    var scgMetaValue, comscoreKeyword;
    var comscoreMappingKey = [];
    var pageUrl = window.location.href;
    var cgMetaTags = document.getElementsByName('CG');
    var scgMetaTags = document.getElementsByName('SCG');
    var comscoreConfig = [ 
        'c1=2', 
        'c2=3005403'
    ];
    var comscoreKeywordMappingObj = {
        "business" : "business",
        "business - global" : "global",
        "business - international" : "global",
        "Business Day - Dealbook" : "dealbook",
        "business - economy" : "economy",
        "business - energy-environment" : "energy_environment",
        "business - media" : "media",
        "business - smallbusiness" : "smallbusiness",
        "your-money" : "your_money",
        "Business Day - Economy" : "economix",
        "Business - Media and Advertising" : "mediadecoder",
        "Business Day - Small Business" : "boss",
        "Business Day - Your Money" : "bucks",
        "Business - Markets" : "markets",
        "Autos - wheels" : "wheels",
        "Science - Environment" : "green",
        "technology" : "technology",
        "technology - personaltech" : "personaltech",
        "Technology - bits" : "bits",
        "Technology - Personal Tech" : "gadgetwise",
        "Technology - pogue" : "pogue",
        "General - open" : "open",
        "style" : "style",
        "fashion" : "fashion",
        "dining" : "dining",
        "garden" : "garden",
        "fashion - weddings" : "weddings",
        "t-magazine" : "t_magazine",
        "T:Style - tmagazine" : "t_style",
        "Style - Dining" : "dinersjournal",
        "Style - Fashion" : "runway",
        "Style - parenting" : "parenting",
        "arts" : "arts",
        "arts - design" : "design",
        "books" : "books",
        "arts - dance" : "dance",
        "movies" : "movies",
        "arts - music" : "music",
        "arts - television" : "television",
        "theater" : "theater",
        "arts - video-games" : "video_games",
        "Arts - Event Search" : "event_search",
        "Arts - artsbeat" : "artsbeat",
        "Movies - carpetbagger" : "carpetbagger",
        "health" : "health",
        "health - research" : "research",
        "health - nutrition" : "nutrition",
        "health - policy" : "policy",
        "health - views" : "views",
        "Health - Health Guide" : "health_guide",
        "Health - well" : "well",
        "Health - newoldage" : "newoldage",
        "Health - consults" : "consults",
        "science" : "science",
        "science - earth" : "earth",
        "science - space" : "space",
        "Science - Environment" : "green",
        "Science - scientistatwork" : "scientistatwork",
        "Opinion - dotearth" : "dotearth"
    };

    if (cgMetaTags.length > 0) {
        comscoreMappingKey.push(cgMetaTags[0].content);
    }
    if (scgMetaTags.length > 0) {
        scgMetaValue = scgMetaTags[0].content;
        if (scgMetaValue !== "") {
            comscoreMappingKey.push(scgMetaValue);
        }
    }
    comscoreKeyword = comscoreKeywordMappingObj[comscoreMappingKey.join(' - ')];

    if (pageUrl.indexOf("markets.on.nytimes.com") !== -1) { // check if its a markets page
        if (pageUrl.indexOf("analysis_tools") !== -1) {
            comscoreKeyword = "analysis_tools";
        }
        else if (pageUrl.indexOf("screener") !== -1) {
            comscoreKeyword = "screener";
        }
        else if (pageUrl.indexOf("portfolio") !== -1) {
            comscoreKeyword = "portfolio";
        }
    }

    if (comscoreKeyword) {
        comscoreConfig.push('comscorekw=' + comscoreKeyword);
    }

    var callback = function() {
        var udmURL = 'http'+(document.location.href.charAt(4)=='s'?'s://sb':'://b')+'.scorecardresearch.com/b?';
        udmURL += comscoreConfig.join('&');

        // Vendor code
        function udm_(a){var b="comScore=",c=document,d=c.cookie,e="",f="indexOf",g="substring",h="length",i=2048,j,k="&ns_",l="&",m,n,o,p,q=window,r=q.encodeURIComponent||escape;if(d[f](b)+1)for(o=0,n=d.split(";"),p=n[h];o<p;o++)m=n[o][f](b),m+1&&(e=l+unescape(n[o][g](m+b[h])));a+=k+"_t="+ +(new Date)+k+"c="+(c.characterSet||c.defaultCharset||"")+"&c8="+r(c.title)+e+"&c7="+r(c.URL)+"&c9="+r(c.referrer),a[h]>i&&a[f](l)>0&&(j=a[g](0,i-8).lastIndexOf(l),a=(a[g](0,j)+k+"cut="+r(a[g](j+1)))[g](0,i)),c.images?(m=new Image,q.ns_p||(ns_p=m),m.src=a):c.write("<","p","><",'img src="',a,'" height="1" width="1" alt="*"',"><","/p",">")}

        udm_(udmURL);
    };

    var s = document.createElement("script"),
       el = document.getElementsByTagName("script")[0];
    s.async = true;
    s.src = (document.location.protocol == "https:" ? "https://sb": "http://b") + ".scorecardresearch.com/c2/3005403/cs.js";
    if (s.addEventListener) { // normal browsers
        s.addEventListener('load', function() {
            callback();
        }, false);
    } 
    else {
        s.onreadystatechange = function() { // old IEs
            if (s.readyState in {loaded: 1, complete: 1}) {
                s.onreadystatechange = null;
                callback();
            }
        };
    }
    el.parentNode.insertBefore(s, el);
})(); // end comscore tagging

// Nielsen tagging
(function () {
  var d = new Image(1, 1);
  d.onerror = d.onload = function () {
    d.onerror = d.onload = null;
  };
  d.src = ["//secure-us.imrworldwide.com/cgi-bin/m?ci=us-nytimes&cg=0&cc=1&si=",
           escape(window.location.href), "&rp=", escape(document.referrer),
           "&ts=compact&rnd=", (new Date()).getTime()].join('');
})();

// Charbeat beacon
function isGlobalEdition() {
    var edition = unescape(document.cookie).match('NYT-Edition=([^;]+)');
    return (edition && edition[1] && edition[1].indexOf("edition|GLOBAL") !== -1);
}

// forms chartbeat domain based on the environment and edition
function getChartbeatDomain() {
    var domain = '';
    if (isGlobalEdition()) {
        domain = "international.nytimes.com";
        if (NYTD.env === "staging") {
            domain = "international.stg.nytimes.com";
        }
    } else {
        domain = "nytimes.com";
        if (NYTD.env === "staging") {
            domain = "stg.nytimes.com";
        }
    }
    return domain;
}

var _sf_async_config = {
    uid: 16698,
    domain: getChartbeatDomain(),
    pingServer: "pnytimes.chartbeat.net",
    path:window.location.pathname,
    title: window.TimesPeople && TimesPeople.Page && TimesPeople.Page.getTitle() || document.title.replace('- NYTimes.com', '')
};

try {
  _sf_async_config.sections = [document.getElementsByName('CG')[0].content, document.getElementsByName('SCG')[0].content].join(",");
} catch(e){}

try {
  _sf_async_config.authors = (document.getElementsByName('byl')[0] || document.getElementsByName('CLMST')[0]).content.replace('By ', '').toLowerCase().replace(/\b[a-z]/g, function(){return arguments[0].toUpperCase();});
} catch(e){}

 (function() {
    function loadChartbeat() {
        window._sf_endpt = (new Date()).getTime();
        includeJsFile((("https:" == document.location.protocol) ? "https://a248.e.akamai.net/chartbeat.download.akamai.com/102508/" : "http://static.chartbeat.com/") + "js/chartbeat.js");
    }
    
    if (window.addEventListener) {
      window.addEventListener('load', loadChartbeat, false);
    } else if (window.attachEvent) {
      window.attachEvent('onload', loadChartbeat);
    } 

 })();

// UPTracker
var NYTD = NYTD || {};
if (! NYTD.Hosts) NYTD.Hosts = {};
if (! NYTD.Hosts.jsHost) NYTD.Hosts.jsHost = "http://js.nyt.com";
NYTD.UPTracker = (function () {
    
    // default configuration
  var config = {
    baseUrl: '//up.nytimes.com/?',
    defaultArguments: 'd=0//&c=1'
  };

  var url;
  
  function init (params) {

    if (params.baseUrl) {
      config.baseUrl = params.baseUrl;
    }
    if (params.eventType) {
      config.eventType = params.eventType;
    }
    if (params.data) {
      config.data = params.data;
    }
    if (params.userID) {
      config.userID = params.userID;
    }
    
    config.url = params.url || window.location.href;
  };
  
  function createUrl() {
  
      // begin with baseUrl
    url = config.baseUrl + config.defaultArguments;
    
      // append eventType
    if (config.eventType) {
      url += '&e=' + config.eventType;
    }

      // add user id if we have one
    if (config.userID) {
      url += '&ui=' + config.userID;
    }
    
      // url encode and append url
    url += '&u=' + encodeURIComponent(config.url);
    
      // url encode and append referrer
    url += '&r=' + encodeURIComponent(document.referrer);

      // if we have meta data, encode and append it
    if (config.data) {
      try {
        JSON.stringify({world:'peace'});
        appendAndSend();        
      } catch (e) {  // if no JSON, inlcude json2-min
        var script = document.createElement('script');
        script.type = "text/javascript";
        script.src  = "//www.nytimes.com/js/app/lib/json/json2-min.js";
        script.onload = function () { 
          appendAndSend(); 
        };
        script.onreadystatechange = function () {
          if (this.readyState == 'loaded' || this.readyState == 'complete') {
            appendAndSend();  
          }
        };
        
        document.getElementsByTagName("head")[0].appendChild(script);
      }
    } else {
      send();
    }
  }; 

  function appendAndSend() {
    var jsonData = JSON.stringify(config.data);
    if (jsonData) {
      url += '&p=' + encodeURIComponent(jsonData);
    }
    send ();
  }
  
  function send() {
    if (url) {
        var img = document.createElement('img');
        img.setAttribute('border', 0);
        img.setAttribute('height', 0);
        img.setAttribute('width', 0);
        img.setAttribute('src', url);
        document.body.appendChild(img);
    } else {
      return false;
    }
  };

  return {
    track: function (params) {
      var params = params || {};
      init(params);
      createUrl();
    },
    check: function (){
                  var imageTags = document.getElementsByTagName('img');
            var UPTcalled = false;
                  var pattern = /up\.nytimes\.com\//;
            for (var i=0; i < imageTags.length; i++){
                          if ( pattern.test(imageTags[i].src)){
                            UPTcalled = true;
          break;
                          }
                  }
                  if (!UPTcalled) {
                          NYTD.UPTracker.track(); // set generic UPT call if not available on page load
                  }
          }
  };
})();

if (window.addEventListener) {
  window.addEventListener('load', NYTD.UPTracker.check, false);

} else if (window.attachEvent) {
  window.attachEvent('onload', NYTD.UPTracker.check);
}


NYTD.EventTracker = (function () {
    'use strict';
    var etHost;
    var lastEventTime = 0;
    var nextCallbackNum = 0;
    var wtMetaExcludes = {
        'wt.z_nyts': 1,
        'wt.z_nytd': 1,
        'wt.z_ref': 1,
        'wt.z_rmid': 1
    };

    etHost = (function () {
       var
         etHost = "et.nytimes.com",
         hosts = ["et.stg.use1.nytimes.com", "et.dev.use1.nytimes.com"];

      if (NYTD !== undefined) {
         // Use the NYTD.env, if available.
         if (NYTD.env !== undefined) {
            if (NYTD.env === "stg" || NYTD.env === "staging") {
               etHost = hosts[0];
            } else if (NYTD.env === "dev" || NYTD.env === "development") {
               etHost = hosts[1];
            }
         } else if (NYTD.Host !== undefined && typeof NYTD.Host.getEnv === "function") {
            // Use NYTD.Host.getEnv() function if available.
            if (NYTD.Host.getEnv() === "stg" || NYTD.Host.getEnv() === "staging") {
               etHost = hosts[0];
            } else if (NYTD.Host.getEnv() === "dev" || NYTD.Host.getEnv() === "development") {
               etHost = hosts[1];
            }
         } else {
            // Last resource, checks the hostname.
            if (/\.stg\.nytimes\.com$/.test(location["hostname"]) === true) {
               etHost = hosts[0];
            } else if (/\.dev\.nytimes\.com$/.test(location["hostname"]) === true) {
               etHost = hosts[1];
            }
         }
      }

      // Return the event tracker hostname.
      return etHost;
   })();
    

    var buildUrl = function (url, params) {
        var key;
        var qs = '';
        for (key in params) if (params.hasOwnProperty(key)) {
            qs += (qs ? '&' : '') + key + '=' + encodeURIComponent(params[key]);
        }
        if (qs.length > 0) {
            return url + '?' + qs;
        } else {
            return url;
        }
    };

    var copyObject = function (obj) {
        var key;
        var objCopy = {};
        for (key in obj) if (obj.hasOwnProperty(key)) {
            objCopy[key] = obj[key];
        }
        return objCopy;
    };

    var extractMetaTags = function (obj) {
        var name, nameLower, content, i;
        var tags = document.getElementsByTagName('meta');
        obj = obj || {};
        for (i = 0; i < tags.length; i += 1) {
            name = tags[i].getAttribute('name');
            content = tags[i].getAttribute('content');
            if (typeof name === 'string' && typeof content === 'string') {
                nameLower = name.toLowerCase();
                if (nameLower.substr(0, 3) === 'wt.' && 
                    !wtMetaExcludes[nameLower]) {
                    obj[name] = content;
                }
            }
        }
        return obj;
    };

    return function () {
        var trackNow, agentId;
        var that = this;
        var datumId = null;
        var parentDatumId = null;
        var firedFirstEvent = false;
        var scripts = [];
        var queue = [];
        var newData = [];

        if (this instanceof NYTD.EventTracker === false) {
            return new NYTD.EventTracker();
        }

        trackNow = function (evt, options) {
            var scriptElem, oldScriptElem;
            var callbackNum = nextCallbackNum;

            nextCallbackNum += 1;

            NYTD.EventTracker['cb' + callbackNum] = function (result) {
                var i;
                delete NYTD.EventTracker['cb' + callbackNum];
                if (result.status && result.status === 'OK') {
                    if (!datumId && options.buffer) {
                        datumId = result.datumId;
                        for (i = 0; i < queue.length; i += 1) {
                            trackNow(queue[i].evt, queue[i].options);
                        }
                    }
                    if (!agentId) {
                        agentId = result.agentId;
                    }
                    if (options.callback) {
                        options.callback(null, result);
                    }
                } else {
                    if (options.callback) {
                        options.callback(new Error('Event tracking failed'), 
                            result);
                    }
                }
            };

            evt = copyObject(evt);
            if (!options.buffer) {
                evt.instant = '1';
            }
            evt.callback = 'NYTD.EventTracker.cb' + callbackNum;
            if (datumId && options.buffer) {
                evt.datumId = datumId;
            }

            if (options.sendMeta) {
                extractMetaTags(evt);
            }

            if (agentId) {
                evt.agentId = agentId;
            }
            scriptElem = document.createElement('script');
            scriptElem.src = buildUrl((document.location.protocol || 'http:') +
                '//'+etHost+'/', evt);
            document.body.appendChild(scriptElem);

            scripts.push(scriptElem);
            if (scripts.length > 5) {
                oldScriptElem = scripts.shift();
                document.body.removeChild(oldScriptElem);
            }
        };

        this.track = function (evt, options) {
            var newDataItem, key;
            options = options || {};
            if (!options.background) {
                lastEventTime = (new Date()).valueOf();
            }
            
            if(evt.subject !== 'page' && this.getParentDatumId() !== null) {
                evt.parentDatumId = this.getParentDatumId();
            }
            
            if(newData.length > 0) {
                for (var i = 0; i < newData.length; i++) {
                    newDataItem = newData[i];
                    for (key in newDataItem) if (newDataItem.hasOwnProperty(key)) {
                        evt[key] = newDataItem[key];
                    }
                }
                newData = []; // empty the array out for future usage
            }
            
            if (!options.buffer) {
                trackNow(evt, options);
            } else if (datumId || !firedFirstEvent) {
                firedFirstEvent = true;
                trackNow(evt, options);
            } else {
                queue.push({
                    evt: copyObject(evt),
                    options: copyObject(options)
                });
            }
        };
        
        this.updateData = function (oArg) {
            if(oArg instanceof Array) {
                newData = newData.concat(oArg)
            } else if(typeof oArg === 'object') {
                newData.push(oArg);   
            }
        };

        this.hasTrackedEventRecently = function () {
            return ((new Date()).valueOf() - lastEventTime) < 960000;
        };

        this.getDatumId = function () {
            return datumId;
        };
        
        this.getParentDatumId = function() {
            if(parentDatumId === null && 
                NYTD.pageEventTracker && NYTD.pageEventTracker.getDatumId() !== null) {
                parentDatumId = NYTD.pageEventTracker.getDatumId();
            }
            return parentDatumId;
        };
        
        this.pixelTrack = function (evt, qs) {
            var imgsrc, validEvt, validQs;
            validEvt = (function (e) {
                var k;
                if (typeof e !== 'object') {
                    return false;
                }
                for (k in e) if (e.hasOwnProperty(k)) {
                    return true;
                }
                return false;
            }(evt));
            validQs = (typeof qs === 'string' && qs !== '');
            if (!validEvt && !validQs) {
                return;
            }
            imgsrc = (document.location.protocol || 'http:') + '//' + etHost +
                    '/pixel';
            if (validEvt) {
                imgsrc = buildUrl(imgsrc, evt);
            }
            if (validQs) {
                imgsrc += ((imgsrc.indexOf('?') === -1 ? '?' : '&') + qs);
            }
            new Image().src = imgsrc;
        };
    };
})();

NYTD.pageEventTracker = (function (updateFrequency) {
    'use strict';
    var tracker = new NYTD.EventTracker();
    var startTime = (new Date()).valueOf();
    updateFrequency = updateFrequency || 60000;
    var timeoutHandle;
    var bgTrackerTrack = function () {
        tracker.track({
            subject: 'page',
            url: document.location.href,
            referrer: document.referrer,
            totalTime: (new Date()).valueOf() - startTime
        }, {
            background: true,
            buffer: true,
            callback: setUpdateTimeout
        });
    };
    var setUpdateTimeout = function () {
        timeoutHandle = setTimeout(function () {
            if (!tracker.getDatumId()) {
                setUpdateTimeout();
                return;
            } else if (!tracker.hasTrackedEventRecently()) {
                return;
            }
            bgTrackerTrack();
        }, updateFrequency);
    };
    tracker.track({
        subject: 'page',
        url: document.location.href,
        referrer: document.referrer,
        sourceApp: 'nyt4',
        totalTime: 0
    }, {
        sendMeta: true,
        buffer: true,
        callback: setUpdateTimeout
    });
    
    tracker.shortCircuit = function () {
        if (timeoutHandle) {
            clearTimeout(timeoutHandle);
        }
        bgTrackerTrack();
    };

    return tracker;
})();

/*jslint browser: true, devel: true, maxerr: 50, indent: 3 */
/*global NYTD, includeJsFile */
(function (root, factory) {
   "use strict";
   var
      env = null,
      success = false,
      NYTD = root.NYTD,
      getHost,
      i,
      requirejs_valid,
      required_libs = ["foundation/hosts"],
      requirejs_track_lib_name = "foundation/lib/tracking";

   // Define the function that handles the environment discovery.
   getHost = function () {
      var
         host = null,
         STATIC_HTTP = {
            "prd": "//graphics8.nytimes.com",
            "stg": "//static.stg.nytimes.com",
            "dev": "//static.dev.nytimes.com"
         },
         STATIC_HTTPS_PROD = "static.nytimes.com";

      // By default, host points to Production.
      if (location.protocol === "https:") {
         host = STATIC_HTTPS_PROD;
      } else {
         host = STATIC_HTTP["prd"];
      }

      // Get the environment from NYTD.env
      if (typeof NYTD === "object") {
         if (typeof NYTD.env === "string") {
            env = NYTD.env;
         } else if (typeof NYTD.Host === "object" && typeof NYTD.Host.getEnv === "function") {
            env = NYTD.Host.getEnv();
         }
      }
      // Check the environment.
      if (env !== null) {
         switch (env) {
            case "staging":
            case "stg":
               host = STATIC_HTTP["stg"];
               break;
            case "development":
            case "dev":
               host = STATIC_HTTP["dev"];
               break;
         }
      } else {
         // Environment is not available, use the URL location.
         if (/\.stg\.nytimes\.com$/.test(location["hostname"]) === true) {
            host = STATIC_HTTP["stg"];
         } else if (/\.dev\.nytimes\.com$/.test(location["hostname"]) === true) {
            host = STATIC_HTTP["dev"];
         }
      }

      // Return the hostname.
      return host;
   };

   // Retrieve hosts from require js library.
   requirejs_valid = true;
   if (typeof require === "function" && typeof require.defined === "function") {
      if (typeof define === "function" && typeof define.amd === "object" && typeof requirejs === "function") {
         // Need to check if foundation/hosts is defined.
         for (i = 0; i < required_libs.length; i += 1) {
            requirejs_valid = requirejs_valid && (requirejs.defined(required_libs[i]) === true);
         }
         if (requirejs_valid === true) {
            // For development purposes, undefined the requirejs_track_lib_name.
            requirejs.undef(requirejs_track_lib_name);
            define(
               requirejs_track_lib_name,
               required_libs,
               function (hosts) {
                  var
                     host = null;

                  if (typeof hosts === "object" && typeof hosts.js === "string") {
                     host = hosts.js;
                  } else {
                     host = getHost();
                  }
                  return host;
               }
            );

            // Call the function to set up the lib.
            require(
               [requirejs_track_lib_name],
               function (host) {
                  // Load from required hosts.
                  factory(host);
               }
            );
         } else {
            factory(getHost());
         }

         // Confirmation that factory was called.
         success = true;
      }
   }

   // // If define and requirejs functions doesn't exists.
   if (success === false) {
      factory(getHost());
   }
}(
   this,
   function (host) {
      "use strict";
      var
         src,
         script;

      // Host.jshost is not reliable.
      if (/\/\/www\.(stg\.|dev\.)?nytimes\.com$/.test(host) === true) {
         host = host.replace(/\/\/www\.(stg\.|dev\.)?nytimes\.com$/, "//static.$1nytimes.com");
      }

      // Load the script.
      src = host + "/bi/js/tagx/tagx.js";
      if (typeof includeJsFile === "function") {
         // Include using function.
         includeJsFile(src, true);
      } else {
         // Include manually.
         script = document.createElement("script");
         script.src = src;
         document.body.appendChild(script);
      }
   }
));

/* END ANALYTICS TRACKING */
/* NOTE: ALL NEW CODE NEEDS TO BE ADDED ABOVE THIS LINE */
}
