.. warning::

   Every line must fit within one TCP packet; ``telnetd`` does only very
   minimal parsing and will not reassemble an over-long line!  Typically,
   a line-buffered program like ``nc`` will be good enough about this that
   it's OK in practice, so long as you send short enough lines!

Overlay Modules
###############

Files of the form ``telnetd-${foo}.lc`` are consulted by ``telnetd`` if the
first word of a line is ``${foo}``; the next word is used to pull a function
from a dictionary, and the rest of the line, together with a function for
sending a response, is passed in to the function so retrieved.

* ``telnetd/telnetd-diag.lua`` -- overlay for interpreting "diag" commands.

  * ``boot`` returns the bootreason values (``node.bootreason()``)
  * ``heap`` shows how much heap is available (``node.heap()``)
  * ``info`` displays ``node.info()``
  * ``fifo`` shows ``rtcfifo.count()`` if ``rtcfifo`` has been initialized
  * ``exec`` is the most useful: it runs ``loadstring`` and ``pcall`` on the remainder of the line.

* ``telnetd/telnetd-file.lua`` -- overlay for interpreting "file" commands.

  * ``info`` shows bytes allocated and free
  * ``list`` dumps a list of files and their sizes
  * ``remove`` does what it says on the tin
  * ``compile`` likewise
  * ``pwrite`` is a positional-write command, used by ``host/pushvia.expect``; it
    takes an offset, file name, and a base64-encoded blob.  The
    all-in-one-packet requirement of ``telnetd`` limits the length of the
    blob; ``host/pushvia.expect`` tries to be quite conservative.
  * ``pread`` is the read dual of ``pwrite``; takes a length, an offset, and
    a file name, and returns a base64-encoded blob.  Be careful that length
    is reasonable, to minimize heap usage.
  * ``sha256`` reports the ASCII-fied hex of the file given, useful for
    verification of flash contents.
  * ``cert`` loads a file in its entirety and passes it to ``net.cert.verify``.
    Be careful, as this can use a lot of heap.

Some useful commands
####################

Schedule a reboot of the node "soon"; we need to give the ESP stack enough
time to write back the prompt, or we risk racing and panic-ing the stack::

  diag exec tmr.create():alarm(1000, tmr.ALARM_SINGLE, node.restart)
