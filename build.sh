#!/bin/bash
set -e -x

export GOPATH=`pwd`
export PATH="$GOPATH/bin:$PATH"

go get github.com/rakyll/statik
go get github.com/tealeg/xlsx

pushd src/server
$GOPATH/bin/statik -src "$GOPATH/pages/"
popd

go build server
echo "Build complete - run your server using ./server"
