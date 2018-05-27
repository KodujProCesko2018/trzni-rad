### getCoords je python program, do kterého vstupuje modifikované CSV s adresami a který vrací geojson se souřadnicemi těchto objektů

Modifikace CSV souboru je popsána v readme složky [data](../data/README.md). Modifikace extrahuje názvy ulic, adresní čísla, katastrální parcely a katastrální území z původního textu v .DOC tabulce, která je přílohou tržního řádu.

Program získává souřadnice ze služby WFS na základě parametrů ulice, číslo domovní, případně číslo orientační, nebo na základě pracelního čísla a čísla katastrálního území. Služba je poskytována Českým úřadem zeměměřickým a katastrálním, na základě dostupných parametrů je volána buď služba pro INSPIRE Adresy:

$ http://services.cuzk.cz/wfs/inspire-ad-wfd.asp?

nebo pro INSPIRE Parcely:

$ http://services.cuzk.cz/wfs/inspire-cp-wfd.asp?

V obou případech je využíváno předpřipravených dotazů. Jejich popis je dostupný zde.

$ http://services.cuzk.cz/wfs/inspire-ad-wfs.asp?service=WFS&version=2.0.0&request=describeStoredQueries&storedQuery_id=GetAddressByComponents

$ http://services.cuzk.cz/wfs/inspire-cp-wfs.asp?service=WFS&version=2.0.0&request=describeStoredQueries&storedQuery_id=GetParcel

## Pořadí preference parametrů

Z důvodu značné nepřesnosti vstupních dat bylo zvoleno pořadí parametrů, podle kterých jsou dotazy volány:

1. Pokud záznam obsahuje název ulice a dvojici číslo popisné/číslo orientační, jsou souřadnice zjišťovány na základě těchto parametrů. V některých případech je pořadí číslo popisné/číslo orientační ve zdrojových datech prohozeno. V případě, že při použití standardního pořadí služba nic nevrací, je dotaz volán znovu s opačným pořadím čísel.
1. Pokud záznam obsahuje pouze jedno číslo, je předpokládáno, že se jedná o číslo orientační. Analýzou dat bylo zjištěno, že ve většině případů je samostané číslo číslem orientačním. Ve zbytku případů o informaci přijdeme.
1. Pokud číslo neobsahuje, vyhledáváme na základě kombinace parcely a katastrálního území. 
1. V případě chybějících čísel vyhledáváme na základě ulice. Jako souřadnice jsou použity náhodně souřadnice jednoho adresního místa v ulici.

Jako obec je ve všech případech použita Praha s kódem 554782, v pžípadě, že je vyplněn atribut  městská část, je výběr omezen i na ní. Bohužel, městská část je v mnoha případech vyplněna chybně.

*Poznámka: v mnoha případech je v textu uvedeno více čísel, ulic nebo čísel katastrálních parcel. Z důvodu vyhnutí se duplikacím v tržních místech je v těchto případech dotazováno pouze na první hodnotu ze seznamu.*

## Extrakce souřadnic:

Výstupem z WFS služby jsou data ve formátu GML odpovídající datovým specifikacím pro INSPIRE téma Adresy, potažmo Parcely. Data jsou validní proti XML schématům pro tato témata. Z dat adres jsou souřadnice extrahovány z elementu `ad:geometry`, parcely mají v elementu `cp:geometry` uložen polygon, proto je definiční bod extrahován z elementu `cp:referencePoint`.

## Tvorba souboru `geojson`

K vytváření objektu json je použita python knihovna `json`. 
Root element je podle specifikace geojson typu `FeatureCollection`. Jednotlivé objekty jsou prvky pole `features`. Každý feature má typ 'Feature', geometrii a seznam vlastností. Vlastnostmi jsou v podstatě všechny sloupce ze vstupního souboru CSV. Sloupec s prodávaným zbožím je rozdělen na jednotlivé druhy zboží a uložen jako pole. Druh zboří slouží k pozdější filtraci výsledků. Souřadnice jsou společně s typem uloženy jako `geometry`. Samotné souřadnice jsou `array`. Všechny spuřadnice jsou uůoženy v souřadnicovém systému EPSG:4326, tedy WGS-84.
