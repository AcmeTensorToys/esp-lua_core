############################################
nwf's nodemcu/ESP8266 framework and projects
############################################

Introduction
############

This is a collection of Lua modules I've used in various nodemcu/ESP8266
projects.  It's largely an overlay-style approach to code residency: most
things are fetched through the ``OVL`` table created by ``init.lua`` rather
than ``require``.

The files here are available under the GNU Affero General Public License,
version 3 or later.  See ``COPYING`` for details.

What's Here
###########

``init.lua`` is the centerpiece of the whole thing.  It knows how to wait at
startup for user input or at a prompt with the network up and telnetd
listening after a panic.  Spawns ``init2.lc`` for project-specific code.
Note that ``init.lua`` tries very hard to have a minimal footprint in the
non-panic path.  It leaves a single global registered in the non-panic path,
``OVL``, which is based on the LFS+SPIFFS loader example shipped with
nodemcu.  ``OVL.foo`` or ``OVL["foo"]`` will attempt to fetch ``foo.lua`` or
``foo.lc`` from SPIFFS and then ``foo`` from LFS; the rest of the modules
here tend to reference each other that way.  (Unlike ``require``, each
``OVL`` fetch is *a distinct object*, so some modules continue to use the
former when they abuse shared state.)

Generic Utilities
-----------------

* ``util/diag.lua`` -- a simple set of diagnostic calls intended for general
  calling from the command line.  A quick overview of the device.  Use as
  ``OVL.diag()``.

* ``host/pushinit.sh`` -- a host-side utility to push a minimum set of files
  up to the device, either via `luatool
  <https://github.com/4refr0nt/luatool>`_ or via an existing telnet server
  with file overlay (see below).  See the readme in ``host/`` for more.


Networking Utilities
--------------------

* The ``fifosock`` module that used to be here has been merged into NodeMCU!
  See ``lua_modules/fifo/fifosock.lua`` in its repository or perhaps skip to
  https://nodemcu.readthedocs.io/en/dev/lua-modules/fifosock/ .

Networking Framework
--------------------

* ``net/nwfnet.lua`` -- an event dispatch module; load with require so that
  there is a singleton instance.

* ``nwfnet-diag.lua`` -- generic event reporting using the above; intended
  as diagnostics from console.  Use as ``OVL["nwfnet-diag"]()(true)`` to
  enable or ``...(false)`` to disable.

* ``net/nwfnet-go.lua`` -- bring up the network and dispatch events via
  ``nwfnet`` above.  Use via ``OVL``.

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

Deprecated
##########

Timer Queue
-----------

.. warning::

   Now that nodemcu supports dynamic timers, this is much less interesting
   unless you imagine having periods of very large numbers of events
   pending, as each referenced dynamic timer holds a slot in the lua
   registry, which never shrinks from its maximum occupancy.

   This module is still used within several modules here, however, for the
   moment.  Its removal and deprecation is being staged.

   It will probably never go away because it has proven itself quite useful
   in adapting other timer frameworks to emulate nodemcu's dynamic timers!

* ``tq/tq.lua`` -- a tickless event queue wrapping around a single nodemcu
  timer.  Useful for managing complex lifecycles and/or many infrequent events.
  Enqueue events with ``:queue(time,function,args...)``; ``:queue`` returns
  a handle suitable for use with ``:dequeue()`` to unregister a pending
  future event.  All ESP-specific behavior is overridable by replacing
  ``:now`` and ``:arm``.  Use as ``tq = OVL.tq()(timer)``.

* ``tq/tq-diag.lua`` -- knows how to traverse a ``tq`` for diagnostic
  utility.  Use as ``OVL["tq-diag"]()(tq,print,print)``, e.g.


