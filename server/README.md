# Jak spustit server

Nejdřív je nutné zkompilovat zdrojový kód

-  nainstaluj si Go
-  zjisti si hodnotu proměnné GOPATH (příkazem $ go env GOPATH)
-  vyexportuj si ji `export GOPATH=$(go env GOPATH)`
-  vytvoř složku `mkdir $GOPATH/src/github.com/KodujProCesko2018`
-  přesuň se tam `cd $GOPATH/src/github.com/KodujProCesko2018`
-  naklonuj naše git repo `git clone https://github.com/KodujProCesko2018/trzni-rad.git`
-  přesuň se do složky kde máš soubor "geo.json"
-  napiš `go build github.com/KodujProCesko2018/trzni-rad/server`

Tadááá! Máš hotovou binárku ve složce, kde máš i nezbytný soubor "geo.json".

Příští kompilace je už jen poslední krok - napsání `go build github.com/KodujProCesko2018/trzni-rad/server`


## Spuštění

Binárka potřebuje ke správnému fungování soubor "geo.json".

Binárku lze spustit pomocí

$ ./server

Nebo s parametry (pro produkční nasazení)

$ ./server --host <verejna-ip> --port 80