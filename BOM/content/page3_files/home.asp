
	var wsodModule = [];

	wsodModule.push('<div id="wsod-home"><span class="tradeTimea">At 8:12 AM ET</span><h4><a href="http://markets.on.nytimes.com/research/markets/overview/overview.asp">Markets &#187;</a></h4>');
wsodModule.push('<div class="marketContainer" style="_width:48px;">Britain<div class="marketLabel"><a href="http://markets.on.nytimes.com/research/markets/usmarkets/snapshot.asp?symbol=572009" class="">FTSE 100</a></div><div><span class="posLast">6,604.83</span></div><div><span class="posChange">+28.67</span></div><div><span class="posChangePct">+0.44%</span></div></div><div class="marketContainer mMarket" style="_width:48px;">Germany<div class="marketLabel"><a href="http://markets.on.nytimes.com/research/markets/usmarkets/snapshot.asp?symbol=569857" class="">DAX</a></div><div><span class="posLast">8,833.03</span></div><div><span class="posChange">+21.05</span></div><div><span class="posChangePct">+0.24%</span></div></div><div class="marketContainer" style="_width:48px;">France<div class="marketLabel"><a href="http://markets.on.nytimes.com/research/markets/usmarkets/snapshot.asp?symbol=585994" class="">CAC 40</a></div><div><span class="posLast">4,267.51</span></div><div><span class="posChange">+27.87</span></div><div><span class="posChangePct">+0.66%</span></div></div><div class="disclaimer">Data delayed at least 15 minutes</div>');
	wsodModule.push('<div class="clearElm"></div></div>');
	
	var destModule = document.getElementById("wsodMarketsChart");
	if (destModule) {
		destModule.innerHTML = wsodModule.join("");
	}