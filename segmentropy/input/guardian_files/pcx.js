/* AG-develop 13.01.24-242 (2013-01-24 10:04:33 CET) */
rsinetsegs=[];
if(rsinetsegs.length>0){
var i=1;
var url="//pixel.mathtag.com/event/img?mt_id=153916&mt_adid=106580&no_log=true";
for(var x=0;x<rsinetsegs.length&&url.length<2000;++x){
    if(x>=20){
        url+="&s"+i+"="+rsinetsegs[x];
        i++;}
    else{
            var y=x+1;
            url+="&v"+y+"="+rsinetsegs[x];}
    }
asi_makeGIF(url);}