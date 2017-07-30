############################################
nwf's nodemcu/ESP8266 framework and projects
############################################

Introduction
############

This is a collection of Lua modules I've used in various nodemcu/ESP8266
projects.  It's largely an overlay-style approach to code residency; many
things are intended to be ``dofile()``'d or ``loadfile()``'d and kept around
only while being used.

The files here are available under the GNU Affero General Public License,
version 3 or later.  See ``COPYING`` for details.

What's Here
###########

``init.lua`` is the centerpiece of the whole thing.  It knows how to wait at
startup for user input or at a prompt with the network up and telnetd
listening after a panic.  Spawns ``init2.lc`` for project-specific code.
Note that ``init.lua`` tries very hard to have a minimal footprint in the
non-panic path and registers no globals and leaves no callbacks registered.

Generic Utilities
-----------------

* ``util/diag.lua`` -- a simple set of diagnostic calls intended for general
  calling from the command line.  A quick overview of the device.  Use as
  ``dofile("diag.lc")``.

* ``host/pushinit.sh`` -- a host-side utility to push a minimum set of files
  up to the device, either via `luatool
  <https://github.com/4refr0nt/luatool>`_ or via an existing telnet server
  with file overlay (see below).  See the readme in ``host/`` for more.

Timer Queue
-----------

* ``tq/tq.lua`` -- a tickless event queue wrapping around a single nodemcu
  timer.  Useful for managing complex lifecycles and/or many infrequent events.
  Enqueue events with ``:queue(time,function,args...)``; ``:queue`` returns
  a handle suitable for use with ``:dequeue()`` to unregister a pending
  future event.  All ESP-specific behavior is overridable by replacing
  ``:now`` and ``:arm``.  Use as ``tq = dofile("tq.lc")(timer)``.

* ``tq/tq-diag.lua`` -- knows how to traverse a ``tq`` for diagnostic
  utility.  Use as ``dofile("tq-diag.lc")(tq,print,print)``, e.g.


Networking Utilities
--------------------

* ``util/fifosock.lua`` -- wraps around the nodemcu/ESP8266 socket sending
  side to provide FIFO execution of ``:send`` calls.  Absent such a
  facility, each ``:send`` is run asynchronously as its own task.

Networking Framework
--------------------

* ``net/nwfnet.lua`` -- an event dispatch module; intended to be resident at
  all times.

* ``nwfnet-diag.lua`` -- generic event reporting using the above; intended
  as diagnostics from console.  Use as ``dofile("nwfnet-diag.lc")(true)`` to
  enable or ``...(false)`` to disable and unload.

* ``net/nwfnet-go.lua`` -- bring up the network and dispatch events via
  ``nwfnet`` above.  Use via ``dofile``.

* ``net/netnet-sntp.lua`` -- utilities for invoking SNTP time
  synchronization once or repeatedly (using ``tq``, below).  Reads server
  address from ``nwfnet.conf2`` or defaults to gateways if available.

MQTT Utilities
--------------

* ``net/nwfmqtt.lua`` -- knows how to construct a mqtt client based on a
  config file, make connections with that client (again, based on a config
  file), register a heartbeat action (on a tq), and how to loop over a file
  to make multiple subscriptions.

Telnet Server
-------------

* ``telnetd/telnetd.lua`` -- the main telnet server.  Use as
  ``tcpserv:listen(23,telnetd.server)``.  See the readme in its directory.

cap1188 driver
--------------

* ``cap1188/cap1188.lua`` is a driver for the
  `CAP1188 <http://www.microchip.com/wwwproducts/en/CAP1188>`_ multi-channel
  touch sensor.  ``cap1188/cap1188-init.lua`` knows how to initialize the
  chip through a reset cycle.  See ``examples/lamp/init2.lua`` and
  ``examples/lamp/lamp-touch.lua`` for usage example.

Completed Projects
------------------

* ``examples/lamp`` -- a reimplementation of ``http://filimin.com/`` which
  speaks MQTT and uses the CAP1188 chip above and Adafruit's WS2812 RGB
  LEDs.
