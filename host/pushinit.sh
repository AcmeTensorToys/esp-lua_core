#!/bin/bash
set -e -u

if [ -z ${HOST:-} ]; then
  # Uses LUATOOL to push init and dependencies to the device; bootstrap!
  PUSHCMD="${LUATOOL} --delay 0.1 -p ${MCUPORT} -b ${MCUBAUD}"
  dopush() { ${PUSHCMD} -f $1 -t ${2:-`basename $1`}; }
  dopushcompile() { ${PUSHCMD} -f $1 -t ${2:-`basename $1`} -c; }
else
  # Uses host/pushvia to push everything if HOST is set
  PUSHCMD="./host/pushvia.expect ${HOST} ${PORT:-23}"
  dopush() { ${PUSHCMD} ${2:-`basename $1`} $1; }
  dopushcompile() { ${PUSHCMD} ${2:-`basename $1`} $1 compile; }
fi

dopushcompile util/diag.lua
dopushcompile tq/tq.lua
dopushcompile tq/tq-diag.lua
dopushcompile net/nwfnet.lua
dopushcompile net/nwfnet-sntp.lua
dopushcompile net/nwfnet-go.lua
dopushcompile net/nwfnet-diag.lua
dopush        net/conf/nwfnet.conf
dopush        net/conf/nwfnet.cert
dopush        net/conf/nwfnet.conf2
dopushcompile util/fifosock.lua
dopushcompile telnetd/telnetd.lua
dopushcompile telnetd/telnetd-file.lua
dopushcompile telnetd/telnetd-diag.lua
dopush        init.lua

echo "SUCCESS"
