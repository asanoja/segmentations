/* AG-develop 13.01.24-242 (2013-01-24 10:04:33 CET) */
rsinetsegs=['E05516_50449','E05516_0'];
var rsiExp=new Date((new Date()).getTime()+2419200000);
var rsiSegs="";
var rsiPat=/.*_5.*/;
var rsiPat2=/([^_]{2})[^_]*_(.*)/;
var i=0;
for(x=0;x<rsinetsegs.length&&i<100;++x){if(!rsiPat.test(rsinetsegs[x])){var f=rsiPat2.exec(rsinetsegs[x]);if(f!=null){rsiSegs+=f[1]+f[2];++i;}}}
document.cookie="rsi_segs="+(rsiSegs.length>0?rsiSegs:"")+";expires="+rsiExp.toGMTString()+";path=/;domain=.guardian.co.uk";
if(typeof(DM_onSegsAvailable)=="function"){DM_onSegsAvailable(['E05516_50449','E05516_0'],'e05516');}