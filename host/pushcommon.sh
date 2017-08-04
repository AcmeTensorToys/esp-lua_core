: ${TOPDIR:=`dirname $0`/../}

luafile () {
  if [ -z "${LUADIET:-}" ]; then
    echo "No diet for lua" >&2
    LUAFILE=$1
  else
    DF=$(mktemp -p /tmp esp-pushcommon-XXXXX)
	: ${LUASRCDIET:=${TOPDIR}/_external/luasrcdiet/bin/luasrcdiet}
    if [ ! -x ${LUASRCDIET} ]; then
		echo "No LUASRCDIET (${LUASRCDIET}); bailing out!"
		exit 1
	fi

    if [ -n "${luafilefd:-}" ]; then exec {luafilefd}<&-; fi
    exec {luafilefd}<>${DF}

    echo "Lua diet ${LUADIET}" >&2
    lua5.1 \
      -e "package.path=package.path..';${TOPDIR}/_external/luasrcdiet/?.lua'" \
      ${LUASRCDIET} $1 -o ${DF} \
      --quiet ${=LUADIET} 2>/dev/null
    rm ${DF}
    LUAFILE=/dev/fd/${luafilefd}
  fi
}

if [ -z "${MCUHOST:-}" ]; then
  if [ -z "${LUATOOL:-}" ]; then echo "Need LUATOOL or MCUHOST"; exit 1; fi
  if [ -z "${MCUPORT:-}" ]; then echo "Need MCUPORT or MCUHOST"; exit 1; fi
  if [ -z "${MCUBAUD:-}" ]; then echo "Need MCUBAUD or MCUHOST"; exit 1; fi
  PUSHCMD="${LUATOOL} --delay 0.1 -p ${MCUPORT} -b ${MCUBAUD}"
  dopushtext()    {                ${=PUSHCMD} -f $1         -t ${2:-`basename $1`}    ; }
  dopushlua()     { luafile ${1} ; ${=PUSHCMD} -f ${LUAFILE} -t ${2:-`basename $1`}    ; }
  dopushcompile() { luafile ${1} ; ${=PUSHCMD} -f ${LUAFILE} -t ${2:-`basename $1`} -c ; }
else
  PUSHCMD="${TOPDIR}/host/pushvia.expect ${MCUHOST} ${PORT:-23}"
  dopushtext()    {                ${=PUSHCMD} ${2:-`basename $1`} $1                 ; }
  dopushlua()     { luafile ${1} ; ${=PUSHCMD} ${2:-`basename $1`} ${LUAFILE}         ; }
  dopushcompile() { luafile ${1} ; ${=PUSHCMD} ${2:-`basename $1`} ${LUAFILE} compile ; }
fi
