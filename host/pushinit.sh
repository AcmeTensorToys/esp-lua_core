#!/bin/zsh
set -e -u

. ./host/pushcommon.sh

[ -d firm ] || {
	echo "./firm should be a symbolic link to the nodemcu firmware"
	exit 1
}

dopushcompile firm/lua_modules/fifo/fifo.lua

dopushcompile util/diag.lua
dopushcompile tq/tq.lua
dopushcompile tq/tq-diag.lua
dopushcompile net/nwfnet.lua
dopushcompile net/nwfnet-sntp.lua
dopushcompile net/nwfnet-go.lua
dopushcompile net/nwfnet-diag.lua
#dopushtext   net/conf/nwfnet.conf
#dopushtext   net/conf/nwfnet.cert
#dopushtext   net/conf/nwfnet.conf2
dopushcompile telnetd/telnetd.lua
dopushcompile telnetd/telnetd-file.lua
dopushcompile telnetd/telnetd-diag.lua
dopushlua     init.lua

echo "SUCCESS"
