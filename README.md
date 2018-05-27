# Tržní řád Prahy

Repo pro vývoj konceptu na hackathonu Kóduj pro Česko 2018.

# Motivace a Use-cases

Tržní řád jsou z podstaty (časo)prostorová data, která udávájí co lze kde a kdy prodávat mimo provozovny. V současnoti mají podobu dlouhé strojově nečitelné tabulky bez jasného formátu, se kterou není možné jako s prostorovými daty jakkoliv pracovat. Naším cílem je přispět k narovnání tohoto stavu ve dvou krocích:

  1. Převod stávající tabulky alespoň částečně do prostorového formatu (GeoJson) a její vizualizace na webu.
  1. Elektronizace formuláře pro návrh na změnu přílohy tržního řádu a jeho obohacení o strojově zpracovatelnou prostorovou složku.

## Formulář

[pages](../pages)

## Server

[server](/server)

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
