============================
GNU MediaGoblin init scripts
============================

Run your MediaGoblin server and task queue as services that start
automatically on reboot.

These scripts should free you of some burdens, and if you don't feel you
have any, you might not need them :)

Installation
------------

The easy way
~~~~~~~~~~~~

Run::

    cd <mediagoblin-git-root-here>
    curl http://wandborg.se/mediagoblin-init-scripts/installer.sh | sh

.. warning::

    For this one you must trust the connection between the wandborg.se server
    and you, and whoever has access to that machine (me) enough to compromise
    your entire machine and connected devices.

    The script will by design ask for your ``sudo`` password to install
    the services.

    Think this trust-dependency can be avoided? Feel free to ping me anywhere
    and/or submit a pull request.

The hard but safe way
~~~~~~~~~~~~~~~~~~~~~

1. Download the ``mediagoblin-paster.sh`` script.
2. Opend the ``mediagoblin-celeryd.sh`` script in your favourite text editor.
3. Replace ``MG_ROOT=...`` and ``MG_USER=...`` with values that fit your
   environment.
4. Save the script to ``/etc/init.d/mediagoblin-paster`` (without the ``.sh``
   file extension)
5. Run ``sudo insserv mediagoblin-paster``.
6. *Repeat all steps again, but with mediagoblin-celeryd.*

Now, to start the services, simply run 
``sudo service mediagoblin-paster start`` and
``sudo service mediagoblin-celeryd start``.

License
-------
See LICENSE
