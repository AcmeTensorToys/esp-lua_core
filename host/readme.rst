Useful commands
###############

Pushing a single file from the shell, over telnet::

  (MCUHOST=192.168.0.1 LUADIET=" " ; . ./host/pushcommon.sh; dopushlua init.lua )
  (MCUHOST=192.168.0.1 LUADIET=" " ; . ./host/pushcommon.sh; dopushcompile net/nwfnet.lua )
  (MCUHOST=192.168.0.1             ; . ./host/pushcommon.sh; dopushtext net/conf/nwfnet.conf )

Or over serial::

  (MCUPORT=/dev/ttyUSB0 MCUBAUD=115200 LUADIET=" " ; . ./host/pushcommon.sh; dopushlua init.lua )
  (MCUPORT=/dev/ttyUSB0 MCUBAUD=115200 LUADIET=" " ; . ./host/pushcommon.sh; dopushcompile net/nwfnet.lua )
  (MCUPORT=/dev/ttyUSB0 MCUBAUD=115200             ; . ./host/pushcommon.sh; dopushtext net/conf/nwfnet.conf )

