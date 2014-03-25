/* AG-master 13.10.13-40 (2013-10-13 13:33:59 CEST) */
rsinetsegs=[];
                var rsiExp=new Date((new Date()).getTime()+2419200000);
                var rsiDom='.nytimes.com';
                var rsiSegs="";
                var rsiPat=/.*_5.*/;
		var i=0;
                for(x=0;x<rsinetsegs.length&&i<35;++x){if(!rsiPat.test(rsinetsegs[x])){rsiSegs+='|'+rsinetsegs[x];++i;}}
                document.cookie="rsi_segs="+(rsiSegs.length>0?rsiSegs.substr(1):"")+";expires="+rsiExp.toGMTString()+";path=/;domain="+rsiDom;
                if(typeof(DM_onSegsAvailable)=="function"){DM_onSegsAvailable([],'h07707');}