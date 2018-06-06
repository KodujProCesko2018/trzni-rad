# Tržní řád Prahy

Repo pro vývoj konceptu na hackathonu Kóduj pro Česko 2018.

# Motivace a Use-cases

Tržní řád jsou z podstaty (časo)prostorová data, která udávájí co lze kde a kdy prodávat mimo provozovny. V současnoti mají podobu dlouhé strojově nečitelné tabulky bez jasného formátu, se kterou není možné jako s prostorovými daty jakkoliv pracovat. Naším cílem je přispět k narovnání tohoto stavu ve dvou krocích:

  1. Převod stávající tabulky alespoň částečně do prostorového formatu (GeoJson) a její vizualizace na webu.
  1. Elektronizace formuláře pro návrh na změnu přílohy tržního řádu a jeho obohacení o strojově zpracovatelnou prostorovou složku.

# High-level popis řešení

* Původni tabulka z Wordu jsme pomocí R převedli do CSV
* CSV bylo dale pomoci R vyčištěno - více [zde](data/README.md)
* Tržním místům byly přes katastrální webovou službu v Pythonu přiřazeny souřadnice a byla vyexportována jako GeoJson - více [zde](getCoords/README.md)
* Výsedný trzni-rad.geojson je servírován staticky se zbytkem webu přes server v GO.
* Na webu je dotupná přehledovám mapa tržních míst, které se podařilo z dat vytěžit. Místa lze filtrovat přes typ prodávaného zboží a lze si zobrazit informace o prodejním místě.
* Dále je na webu formulář pro návrh na změnu přílohy tržního řádu obsahující údaje nutné pro následné řízení a navíc mapu, kde žadatel tržní místo (místa) označí polygonem.
* Po odeslání formuláře jsou data uložena do xlsx tabulky na serveru, vyznačené polygony jsou uloženy v tabulce jako GeoJson string v souřadném systému EPSG:4326.

## Formulář

[pages](../pages)

## Server

Server je naprogramován v moderním kompilovaném jazyce Go od společnosti Google.
Slouží jako backend pro formulář, jehož obsah uloží do Excelového souboru trzni-
rad.xlsx. Server pro své fungování potřebuje soubor trzni-rad.geojson. Všechny
soubory musí být/jsou vytvořeny ve stejné složce, v jaké je umístěn spustitelný
soubor serveru.

Pro vytvoření spustitelného souboru `server` resp. `server.exe` pod OS Windows
se stačí se ujistit že máte nainstalované go a poté spustit `build.sh`. Binární
soubor `server` resp. `server.exe` by se měl objevit v kořenu projektu (vedle
souboru build.sh). Tato binárka má v sobě zakomponované statické soubory HTML,
CSS a JS tudíž je naprosto nezávislá na umístění.

Pro vývoj je možné server spustit s parametrem `--debug` který nepoužívá
zakomponované statické soubory, ale servíruje soubory ze složky `pages/`
umístěné vedle souboru `server`.

Pro produkční nasazení server podporuje parametry `--host` a `--port`.

## Prezentace

[na slides.com](https://slides.com/dugi/deck-5/edit)

## Použité technologie

### [Leaflet JS](https://leafletjs.com/), [Leaflet Draw JS](https://github.com/Leaflet/Leaflet.draw)

Leaflet je jednoduchá frontendová Javascriptová knihovna pro zobrazení a práci s mapou na webu. Umožňuje například zobrazit základní mapu a na ní klikací vektorová data. Základní mapa je nyní použitá z free plánu z [Mapboxu], kde je nutné si založit účet dodat vlastni access token. V případě nutnosti lze zádkladní mapu získat i kompletně pomocí opensource nástrojů (Mapnik) z OpenStreetMap databáze, ale je to náročnější.

Leaflet Draw umožuje do mapy kreslit čáry a polygony a ty pak získat ve formě např. [GeoJsonu](http://geojson.org/).

V projektu jsou zdrojové kódy zmražené ve verzích Leaflet: 1.3.1 a Leaflet Draw: 1.0.2. To se týka souborů:
```
css/leaflet.css
css/leaflet.draw.css
css/images/spritesheet.svg (pouzite v css/leaflet.draw.css)

js/leaflet.js
js/leaflet.draw.js
```

### Normalize CSS
### Skeleton CSS
### jQuery JS

## Styly

### Ikony

* [CSS ICON](https://cssicon.space/#/)

### Ostatní (TODO:)

* `<link rel="stylesheet" href="css/normalize.css">`
* `<link rel="stylesheet" href="css/skeleton.css">`

## Skripty (TODO:)

* `<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>`
* `<script src="js/basicMap.js"></script>`
