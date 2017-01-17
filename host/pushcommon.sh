if [ -z ${MCUHOST:-} ]; then
  # Uses LUATOOL to push init and dependencies to the device; bootstrap!
  PUSHCMD="${LUATOOL} --delay 0.1 -p ${MCUPORT} -b ${MCUBAUD}"
  dopush() { ${=PUSHCMD} -f $1 -t ${2:-`basename $1`}; }
  dopushcompile() { ${=PUSHCMD} -f $1 -t ${2:-`basename $1`} -c; }
else
  # Uses host/pushvia to push everything if MCUHOST is set
  PUSHCMD="./host/pushvia.expect ${MCUHOST} ${PORT:-23}"
  dopush() { ${=PUSHCMD} ${2:-`basename $1`} $1; }
  dopushcompile() { ${=PUSHCMD} ${2:-`basename $1`} $1 compile; }
fi
