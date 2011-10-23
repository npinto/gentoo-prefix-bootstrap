============================================================================
Bootstrap a Scientific Gentoo Prefix
============================================================================

License:
--------
Do What The Fuck You Want To Public License (WTFPL)
see LICENSE file

Usage:
------
To get some help:
$ make help

To install everything:
$ make

To uninstall everything:
$ make uninstall

To just install the system:
$ make system

To just install general tools (eix, layman, vim, zsh, etc.):
$ make tools

To just install the scientfic/development environment
(atlas, python, numpy, scipy, mongo, etc.):
$ make scientific(TODO: complete this)

By default the Gentoo Prefix will be installed in $HOME/gentoo but this can
be overriden by specifying the EPREFIX environment variable, for example:
$ EPREFIX=/path/to/my/eprefix make

Successfully tested on:
-----------------------
 * Gentoo ;-)
 * Fedora release 12 (Constantine)
 * CentOS release 5.6 (Final)
 * Ubuntu 11.04 (Natty Narwhal)
 * Ubuntu 10.10 (Maverick Meerkat)
 * Ubuntu 9.10 (Karmic Koala)
 * Mandriva Linux release 2011.0 (Official) for x86_64

More information about Gentoo Prefix:
-------------------------------------

* http://www.gentoo.org/proj/en/gentoo-alt/prefix/
* http://www.gentoo.org/proj/en/gentoo-alt/prefix/usecases.xml
* http://www.gentoo.org/proj/en/gentoo-alt/prefix/bootstrap-solaris.xml

Contributors:
-------------
 * Nicolas Pinto <pinto@alum.mit.edu>
 * Nicolas Poilvert <poilvert@alum.mit.edu>

