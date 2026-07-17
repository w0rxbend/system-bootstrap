#!/usr/bin/env bash
GOPATH=${HOME}/.go

GO_VERSION=1.26.3

# ---
echo "Installing go"
rm -rf $GOPATH
mkdir -p $GOPATH
curl -L -o $GOPATH/go.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -zvxf $GOPATH/go.tar.gz -C $GOPATH 1>/dev/null
echo $GOPATH
mv -f $GOPATH/go/* $GOPATH/
rm -rf $GOPATH/go.tar.gz

mkdir -p ${HOME}/.go-workspace
