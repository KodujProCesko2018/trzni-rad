# Jak spustit server

Nejdřív je nutné zkompilovat zdrojový kód

-  nainstaluj si Go
-  nainstaluj si nezbytné knihovny
-  `go get github.com/rakyll/statik`
-  přidej si $GOPATH/bin do PATH (export PATH=$GOPATH/bin:$PATH) abys mohl pustit statik odkudkoliv
-  `go get github.com/tealeg/xlsx`
-  zjisti si hodnotu proměnné GOPATH (příkazem $ go env GOPATH)
-  vyexportuj si ji `export GOPATH=$(go env GOPATH)`
-  vytvoř složku `mkdir $GOPATH/src/github.com/KodujProCesko2018`
-  přesuň se tam `cd $GOPATH/src/github.com/KodujProCesko2018`
-  naklonuj naše git repo `git clone https://github.com/KodujProCesko2018/trzni-rad.git`
-  přesuň se do složky kde máš soubor "trzni-rad.geojson"
-  zkompiluj `go build github.com/KodujProCesko2018/trzni-rad/server`

Tadááá! Máš hotovou binárku `server` v aktuální složce, kde máš i nezbytný soubor "trzni-rad.geojson".

Kompilace statics (HTML a CSS)
-  jdi do složky server `cd $GOPATH/src/github.com/KodujProCesko2018/trzni-rad/server`
-  přegeneruj soubor statik/statik.go pouzitim `statik -src ../pages/`
-  jdi so složky kde je geoJSON
-  překompiluj server `go build github.com/KodujProCesko2018/trzni-rad/server`
-  binárka (s HTML a statiky vnořenými) se objeví v aktuálním adresáři


## Spuštění

Binárka potřebuje ke správnému fungování soubor "trzni-rad.geojson".

Binárku lze spustit pomocí

$ ./server

Nebo s parametry (pro produkční nasazení)

$ ./server --host <verejna-ip> --port 80