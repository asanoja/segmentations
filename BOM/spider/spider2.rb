require 'nokogiri'
require 'uri'

def to_html(ifname)
str = "<table border='1'>\n" # output string
File.open(ifname).each { |line|
  str += "  <tr><td>" + line.strip.gsub(/\"/,"").gsub(/,$/,"").gsub(/,/,"</td><td>") + "</td>\n"
}
str += "</table>"
str
end

def filename(keyword,pages)
"#{keyword}-#{pages}.csv"
end

def run_spider(keyword,pages)
system "cd google-crawler/;bash executer.sh #{keyword} \"#{pages}\""
puts to_html("./google-crawler/scraped/#{filename(keyword,pages)}")
return "./google-crawler/scraped/#{filename(keyword,pages)}"
end

terms = ["kids","teens","arts","games","reference","shopping","world","business","health","news","regional","society","computers","home","recreation","science","sports"]
terms.each do |t|
	puts "Extrating from #{t}"
	File.open("urllist.html",'a') {|g| g.puts "<h1>"+t+"</h1>"} 
	f=run_spider(t,5)
	puts "Converting..."
	inter = to_html(f)
	URI.extract(inter).each do |url|
		frag = "<a href='#{url}' target='_blank'>#{url}</a><br>\n"
		File.open("urllist.html",'a') {|g| g.puts frag} 
		File.open("urllist.txt",'a') {|g| g.puts url} 
	end
	puts "Done."
end



inter = <<EOF
<table>
  <tr><td>url</td><td>search_tag</td><td>google_page</td><td>google_position</td><td>title</td><td>keywords</td>
  <tr><td>http://it.wikipedia.org/wiki/Computer</td><td>computers</td><td>1</td><td>1</td><td>Computer - Wikipedia</td><td>modifica</td><td> memoria</td><td> macchina</td><td> sistema</td><td> sorgente</td><td> hardware</td><td> sistemi</td><td> software</td><td> essere</td><td> dati</td>
  <tr><td>http://it.wikipedia.org/wiki/Personal_computer</td><td>computers</td><td>1</td><td>2</td><td>Personal computer</td><td>modifica</td><td> personal</td><td> sorgente</td><td> essere</td><td> desktop</td><td> prestazioni</td><td> vedi</td><td> approfondire</td><td> dimensioni</td><td> parte</td>
  <tr><td>http://it.wikipedia.org/wiki/Storia_del_computer</td><td>computers</td><td>1</td><td>3</td><td>Storia del computer</td><td>modifica</td><td> sorgente</td><td> personal</td><td> macchina</td><td> sistema</td><td> Apple</td><td> progetto</td><td> prima</td><td> Xerox</td><td> anni</td>
  <tr><td>http://it.wikipedia.org/wiki/Acorn_Computers</td><td>computers</td><td>1</td><td>4</td><td>Acorn Computers - Wikipedia</td><td>modifica</td><td> computer</td><td> sviluppo</td><td> sorgente</td><td> Micro</td><td> mercato</td><td> Computer</td><td> Curry</td><td> processore</td><td> Cambridge</td>
  <tr><td>http://en.wikipedia.org/wiki/Computer</td><td>computers</td><td>1</td><td>5</td><td>Computer - Wikipedia</td><td> the free encyclopedia</td><td>computers</td><td> that</td><td> program</td><td> machine</td><td> which</td><td> Computer</td><td> from</td><td> first</td><td> with</td><td> Babbage</td>
  <tr><td>http://en.wikipedia.org/wiki/Personal_computer</td><td>computers</td><td>1</td><td>6</td><td>Personal computer - Wikipedia</td><td> the free encyclopedia</td><td>computers</td><td> personal</td><td> with</td><td> that</td><td> system</td><td> edit</td><td> operating</td><td> from</td><td> Windows</td><td> which</td>
  <tr><td>http://www.racomputer.it/</td><td>computers</td><td>1</td><td>7</td><td>RA Computer - Home Page</td><td>specializzazione</td><td> soluzione</td><td> Astore</td><td> Cristina</td><td> misura</td><td> Apri</td><td> Privacy</td><td> Eventi</td><td> fornitura</td><td> Accesso</td>
  <tr><td>http://www.apple.com/it/</td><td>computers</td><td>1</td><td>8</td><td>Apple</td><td>Watch</td><td> Store</td><td> keynote</td><td> Condizioni</td><td> riservati</td><td> diritti</td><td> Copyright</td><td> contattarci</td><td> Opportunit</td><td> Ambiente</td>
  <tr><td>http://www.abscomputers.it/</td><td>computers</td><td>1</td><td>9</td><td>Assistenza informatica Verona</td><td> soluzioni dal 1983 | ABS Computers</td><td>Computers</td><td> servizio</td><td> Help</td><td> Desk</td><td> servizi</td><td> personale</td><td> informazioni</td><td> Ulteriori</td><td> Roll</td><td> tutte</td>
  <tr><td>http://www.computersistemi.it/</td><td>computers</td><td>2</td><td>10</td><td>Computer Sistemi Srl :: Soluzioni Software e Hardware - Fano</td><td>[]</td>
  <tr><td>http://www.biemmecomputers.it/</td><td>computers</td><td>2</td><td>11</td><td>Biemme Computers srl</td><td>prodotti</td><td> Computers</td><td> biemmecomputers</td><td> Gecom</td><td> Biemme</td><td> mail</td><td> Trib</td><td> internet</td><td> info</td><td> sito</td>
  <tr><td>http://www.bitlinecomputers.com/</td><td>computers</td><td>2</td><td>12</td><td>BitLine Computers - Lugo</td><td>[]</td>
  <tr><td>http://www.td-computers.com/</td><td>computers</td><td>2</td><td>13</td><td>TD-Computers via Cicerone</td><td> 7 Santa Marinella tel. 0766535475</td><td>PRESTIGIO</td><td> Curiosit</td><td> tecniche</td><td> Corsi</td><td> Prodotti</td><td> Marinella</td><td> Santa</td><td> calcio</td><td> serie</td><td> partite</td>
  <tr><td>http://www.paoletticomputers.com/</td><td>computers</td><td>2</td><td>14</td><td>Paoletti Computers</td><td>XXIII</td><td> pcpec</td><td> info</td><td> Mail</td><td> Torino</td><td> CENTALLO</td><td> Teresa</td><td> Madre</td><td> CARAGLIO</td><td> Giovanni</td>
  <tr><td>http://www.ique.it/</td><td>computers</td><td>2</td><td>15</td><td>Informatique Computers Aosta</td><td>Aosta</td><td> Festaz</td><td> Scarica</td><td> Computers</td><td> Telesupporto</td>
  <tr><td>http://www.k-computers.it/</td><td>computers</td><td>2</td><td>16</td><td>K-Computers - Tecnological Screaming!!!!</td><td>ogni</td><td> mondo</td><td> software</td><td> qualunque</td><td> posto</td><td> Grazie</td><td> NETWORKING</td><td> bisogno</td><td> backup</td><td> Varese</td>
  <tr><td>http://www.pakypc.it/</td><td>computers</td><td>2</td><td>17</td><td>Paky Computers</td><td>[]</td>
  <tr><td>http://www.idasnc.com/</td><td>computers</td><td>2</td><td>18</td><td>Home - I.D.A. Computers</td><td>[]</td>
  <tr><td>http://www.desandre.it/</td><td>computers</td><td>2</td><td>19</td><td>Desandre Computer | - Aosta</td><td>[]</td>
  <tr><td>http://www.gardacomputers.it/</td><td>computers</td><td>3</td><td>20</td><td>Garda Computers - Consulenza assistenza hardware software</td><td>AZIENDA</td><td> CONTATTI</td><td> AREA</td><td> RISERVATA</td><td> vendita</td><td> SOLUZIONI</td><td> soluzione</td><td> SEDE</td><td> cassa</td><td> SERVIZI</td>
  <tr><td>http://www.omcomputers.it/</td><td>computers</td><td>3</td><td>21</td><td>OMCOMPUTERS - ONLINE STORE</td><td> ONLINE STORE & CATALOG</td><td>color</td><td> size</td><td> weight</td><td> spacing</td><td> meno</td><td> FFFFFF</td><td> letter</td><td> vedi</td><td> Schede</td><td> Ricerca</td>
  <tr><td>http://www.ms-computers.it/</td><td>computers</td><td>3</td><td>22</td><td>MS Computer</td><td>Tecnica</td><td> contenuti</td><td> Home</td><td> Page</td><td> Assistenza</td><td> Mondo</td><td> Education</td><td> Offerte</td><td> Contatti</td><td> Torna</td>
  <tr><td>http://www.computerscenter.com/</td><td>computers</td><td>3</td><td>23</td><td>COMPUTERS CENTER - centro di consulenza</td><td> manuntenzione ...</td><td>Aggiornamento</td><td> versione</td><td> documentazione</td><td> nuova</td><td> CenterMAPPA</td><td> Computers</td><td> progettazione</td><td> Grafica</td><td> Speed</td><td> Nuova</td>
  <tr><td>http://www.recme.it/</td><td>computers</td><td>3</td><td>24</td><td>Recme Computers</td><td>LISTINO</td><td> AZIENDA</td><td> more</td><td> Computer</td><td> Personal</td><td> Read</td><td> Satellitari</td><td> Console</td><td> Gaming</td><td> Lettori</td>
  <tr><td>http://www.jmccomputers.it/</td><td>computers</td><td>3</td><td>25</td><td>Jmc Computers: We realize your ideas!</td><td>MERCATI</td><td> mercato</td><td> sistemi</td><td> tecnologie</td><td> diretta</td><td> partnership</td><td> rapporti</td><td> grazie</td><td> complessi</td><td> componenti</td>
  <tr><td>http://www.lucchesecomputers.com/</td><td>computers</td><td>3</td><td>26</td><td>LUCCHESE COMPUTERS s.r.l.</td><td>italiano</td><td> mercato</td><td> software</td><td> Clienti</td><td> normativa</td><td> Software</td><td> TeamSystem</td><td> Servizi</td><td> aggiornata</td><td> Office</td>
  <tr><td>http://www.nirah.it/</td><td>computers</td><td>3</td><td>27</td><td>Nirah Computers ::: Computer Forli :: Fastweb Forli ::::::::::::::::::::</td><td>Nirah</td><td> Pick</td><td> Forli</td><td> Computers</td><td> ePRICE</td><td> Fastweb</td><td> Computer</td><td> Assistenza</td><td> View</td><td> apertura</td>
  <tr><td>http://www.gigabytecomputers.it/</td><td>computers</td><td>3</td><td>28</td><td>Gigabyte Computers PC Technology Centro Assistenza ... - Scafati</td><td>Visualizza</td><td> Notebook</td><td> carrelloNB</td><td> Intel</td><td> Disk</td><td> processore</td><td> Soluzioni</td><td> Laser</td><td> Mouse</td><td> Core</td>
  <tr><td>http://www.asacomputer.com/</td><td>computers</td><td>3</td><td>29</td><td>ASA Computer</td><td>reserved</td><td> rights</td><td> Computer</td><td> Copyright</td><td> contatti</td><td> line</td><td> notizie</td><td> servizi</td><td> home</td><td> Contatti</td>
  <tr><td>http://www.paginegialle.it/emme3computers</td><td>computers</td><td>4</td><td>30</td><td>EMME 3 COMPUTERS DIGITAL DIVIDE srl - Personal computers ed ...</td><td>cerca</td><td> Seat</td><td> qualsiasi</td><td> indirizzo</td><td> Roma</td><td> software</td><td> hardware</td><td> numero</td><td> computer</td><td> DIGITAL</td>
  <tr><td>http://www.cics-computers.it/</td><td>computers</td><td>4</td><td>31</td><td>C.I.C.S. - Computer's Store - Formigine</td><td>Computer</td><td> assistenza</td><td> Store</td><td> servizio</td><td> scelta</td><td> software</td><td> cics</td><td> computers</td><td> Tablet</td><td> Apple</td>
  <tr><td>http://www.teamviewer.com/it/res/pdf/first-steps-computers-and-contacts-it.pdf</td><td>computers</td><td>4</td><td>32</td><td>first-steps-computers-and-contacts-it - TeamViewer</td><td>rAPQ</td><td> stream</td><td> startxref</td><td> Prev</td><td> trailer</td><td> xref</td><td> endobj</td>
  <tr><td>http://www.ferrari-computers.it/</td><td>computers</td><td>4</td><td>33</td><td>Ferrari Giovanni Computers s.r.l. - Ecommerce - Modena</td><td>Gruppi</td><td> DISK</td><td> Marche</td><td> ESTERNI</td><td> ASUSHARD</td><td> INTEL</td><td> ACER</td><td> mattina</td><td> Tutte</td><td> negozio</td>
  <tr><td>http://www.sudcomputers.it/</td><td>computers</td><td>4</td><td>34</td><td>Home | Sud Computers - Lecce</td><td>Libert</td><td> Viale</td><td> Powered</td><td> Computers</td><td> ACCESSORI</td><td> Stampati</td><td> SOFTWARE</td><td> HARDWARE</td><td> ItalianoEnglish</td><td> Contatti</td>
  <tr><td>http://www.misco.it/</td><td>computers</td><td>4</td><td>35</td><td>Misco - Prodotti</td><td> Servizi e Solutioni IT per il Settore Pubblico</td><td> Grandi ...</td><td>Disk</td><td> Esclusa</td><td> Inclusa</td><td> spots</td><td> Garanzia</td><td> Aziende</td><td> page</td><td> channel</td><td> middle</td><td> Imprese</td>
  <tr><td>https://www.facebook.com/pages/OCM-COMPUTERS-LINE-SRL/102653836449784</td><td>computers</td><td>4</td><td>36</td><td>OCM COMPUTERS LINE SRL - Lanciano</td><td> Italy - Computer Store ...</td><td>dutilisationAide</td><td> PageDveloppeursEmploisConfidentialitCookiesConditions</td><td> publicitCrer</td><td> Franais</td><td> deCrer</td><td> propos</td><td> amisBadgesPersonnesPagesLieuxApplicationsJeuxMusique</td><td> Facebook</td><td> oubli</td><td> passe</td>
  <tr><td>http://www.ferraricomputer.it/</td><td>computers</td><td>4</td><td>37</td><td>Ferrari Computer | Viale Masini 18</td><td> Bologna</td><td>Computer</td><td> Competenza</td><td> Soluzioni</td><td> Sicurezza</td><td> Stampanti</td><td> Allarmi</td><td> Unico</td><td> Socio</td><td> Bologna</td><td> Ferrari</td>
  <tr><td>http://www.ramcomputers.org/</td><td>computers</td><td>4</td><td>38</td><td>RAM Computers s.n.c.</td><td>Arsie</td><td> Legale</td><td> Sede</td><td> Copyright</td><td> SCONTATISSIMI</td><td> Prezzi</td><td> Articoli</td><td> OnlineShop</td><td> FONZASOP</td><td> Belluno</td>
  <tr><td>http://stores.ebay.it/Computers-Parts-Sicilia</td><td>computers</td><td>4</td><td>39</td><td>eBay: Computers Parts Sicilia</td><td>rimasto</td><td> GratisTempo</td><td> mIngrandisciLEXMARK</td><td> Part</td><td> number</td><td> Multifunzione</td><td> eBay</td><td> LASER</td><td> Card</td><td> mIngrandisciSTAMPANTE</td>
  <tr><td>http://www.e-webclub.com/EndUser/index.asp?Dealer=X15282&lang=IT</td><td>computers</td><td>5</td><td>40</td><td>computers di Sergio Paglione</td><td>produttore</td><td> prezzi</td><td> Sconto</td><td> installazione</td><td> Finale</td><td> Disponibilit</td><td> Ricerca</td><td> inclusa</td><td> Listino</td><td> Codice</td>
  <tr><td>http://www.amcomputers.org/</td><td>computers</td><td>5</td><td>41</td><td>Am computers</td><td>Mercatino</td><td> seguici</td><td> Samsung</td><td> link</td><td> HARDWARE</td><td> FeedbackOlark</td><td> Questions</td><td> mobili</td><td> dispositivi</td><td> Disponibile</td>
  <tr><td>http://aziende.virgilio.it/computers-max-di-erbino-massimiliano</td><td>computers</td><td>5</td><td>42</td><td> COMPUTERS MAX DI ERBINO MASSIMILIANO - TEVEROLA ...</td><td>COMPUTERS</td><td> Lorenzo</td><td> COMPUTER</td><td> MASSIMILIANO</td><td> TEVEROLA</td><td> VENDITA</td><td> PERSONAL</td><td> Elettrodomestici</td><td> INFO</td><td> Informatica</td>
  <tr><td>http://www.casalicomputers.com/</td><td>computers</td><td>5</td><td>43</td><td>Casali Computers: Home</td><td>retweet</td><td> favorite</td><td> reply</td><td> Computers</td><td> Casali</td><td> soluzioni</td><td> permette</td><td> entrate</td><td> agenzia</td><td> gestione</td>
  <tr><td>http://www.rgbcomputersweb.com/</td><td>computers</td><td>5</td><td>44</td><td>RGB Computers - Vendita hardware</td><td> software</td><td> gaming e pro-gaming</td><td>processori</td><td> Haswell</td><td> PCIe</td><td> RAIDR</td><td> INTEL</td><td> ASUS</td><td> Vengeance</td><td> Processori</td><td> Intel</td><td> dispositivi</td>
  <tr><td>http://www.albinomarras.it/</td><td>computers</td><td>5</td><td>45</td><td>Albino Marras Computers</td><td>Ottieni</td><td> INTRODUZIONE</td><td> SALTA</td><td> aggiornato</td><td> SKIP</td><td> Player</td><td> INTRO</td><td> Macromedia</td><td> richiede</td><td> sito</td>
  <tr><td>http://www.shark.it/</td><td>computers</td><td>5</td><td>46</td><td>Shark Computers - Roma</td><td>Computers</td><td> JoomlAxe</td><td> mail</td><td> Copyright</td><td> Develop</td><td> Joomlashow</td><td> Review</td><td> gruppo</td><td> Designed</td><td> Template</td>
  <tr><td>http://www.santellocco.com/atari/</td><td>computers</td><td>5</td><td>47</td><td>Atari 8-bit computers: 400/800/XL/XE - Santellocco</td><td>computer</td><td> chip</td><td> serie</td><td> lingua</td><td> grazie</td><td> Commodore</td><td> colori</td><td> pagina</td><td> prodotti</td><td> italiana</td>
  <tr><td>http://computer.howstuffworks.com/</td><td>computers</td><td>5</td><td>48</td><td>HowStuffWorks Computer</td><td>your</td><td> computer</td><td> Videos</td><td> Internet</td><td> Discovery</td><td> Explore</td><td> more</td><td> Hardware</td><td> These</td><td> what</td>
  <tr><td>http://www.scscomputers.it/</td><td>computers</td><td>5</td><td>49</td><td>SCS COMPUTERS S.R.L. - software</td><td> assistenza</td><td> gestionali ... - Fermo</td><td>COMPUTERS</td><td> gestionale</td><td> software</td><td> necessit</td><td> sempre</td><td> altamente</td><td> problematiche</td><td> informatici</td><td> prodotti</td><td> consulenza</td>
</table>
EOF



