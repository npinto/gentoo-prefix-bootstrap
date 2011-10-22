============================================================================
Bootstrap a Scientific Gentoo Prefix
============================================================================

License:
--------
Do What The Fuck You Want To Public License (WTFPL)
see LICENSE file

Usage:
------
To install everything:
$ make
(XXX: right now this just install the system)

To just install the system:
$ make install_system

To just install general tools (eix, layman, vim, zsh, etc.):
$ make install_tools

To just install the scientfic/development environment
(atlas, python, numpy, scipy, mongo, etc.):
$ make install_scientific_environment (TODO)

By default the Gentoo Prefix will be installed in $HOME/gentoo but this can
be overriden by specifying the EPREFIX environment variable, for example:
$ EPREFIX=/path/to/my/eprefix make

Successfully tested on:
-----------------------
 * Fedora release 12 (Constantine)
 * CentOS release 5.6 (Final)
 * Ubuntu 10.10 (Maverick Meerkat)
 * Ubuntu 11.04 (Natty Narwhal)

More information about Gentoo Prefix:
-------------------------------------

* http://www.gentoo.org/proj/en/gentoo-alt/prefix/
* http://www.gentoo.org/proj/en/gentoo-alt/prefix/usecases.xml
* http://www.gentoo.org/proj/en/gentoo-alt/prefix/bootstrap-solaris.xml

Contributors:
-------------
 * Nicolas Pinto <pinto@alum.mit.edu>
 * Nicolas Poilvert <poilvert@alum.mit.edu>

