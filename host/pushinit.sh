#!/bin/zsh
set -e -u

. ./host/pushcommon.sh

dopushcompile util/diag.lua
dopushcompile fifo/fifo.lua
dopushcompile fifo/fifo-diag.lua
dopushcompile tq/tq.lua
dopushcompile tq/tq-diag.lua
dopushcompile net/nwfnet.lua
dopushcompile net/nwfnet-sntp.lua
dopushcompile net/nwfnet-go.lua
dopushcompile net/nwfnet-diag.lua
#dopushtext   net/conf/nwfnet.conf
#dopushtext   net/conf/nwfnet.cert
#dopushtext   net/conf/nwfnet.conf2
dopushcompile net/fifosock.lua
dopushcompile telnetd/telnetd.lua
dopushcompile telnetd/telnetd-file.lua
dopushcompile telnetd/telnetd-diag.lua
dopushlua     init.lua

echo "SUCCESS"
