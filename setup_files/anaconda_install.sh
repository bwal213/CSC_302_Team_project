#!/bin/sh
#
# NAME:  Anaconda3
# VER:   5.3.0
# PLAT:  linux-64
# BYTES:    667822837
# LINES: 810
# MD5:   fc8a64e5937c4b0afd9e0ecb34155ce6

export OLD_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
unset LD_LIBRARY_PATH
if ! echo "$0" | grep '\.sh$' > /dev/null; then
    printf 'Please run using "bash" or "sh", but not "." or "source"\\n' >&2
    return 1
fi

# Determine RUNNING_SHELL; if SHELL is non-zero use that.
if [ -n "$SHELL" ]; then
    RUNNING_SHELL="$SHELL"
else
    if [ "$(uname)" = "Darwin" ]; then
        RUNNING_SHELL=/bin/bash
    else
        if [ -d /proc ] && [ -r /proc ] && [ -d /proc/$$ ] && [ -r /proc/$$ ] && [ -L /proc/$$/exe ] && [ -r /proc/$$/exe ]; then
            RUNNING_SHELL=$(readlink /proc/$$/exe)
        fi
        if [ -z "$RUNNING_SHELL" ] || [ ! -f "$RUNNING_SHELL" ]; then
            RUNNING_SHELL=$(ps -p $$ -o args= | sed 's|^-||')
            case "$RUNNING_SHELL" in
                */*)
                    ;;
                default)
                    RUNNING_SHELL=$(which "$RUNNING_SHELL")
                    ;;
            esac
        fi
    fi
fi

# Some final fallback locations
if [ -z "$RUNNING_SHELL" ] || [ ! -f "$RUNNING_SHELL" ]; then
    if [ -f /bin/bash ]; then
        RUNNING_SHELL=/bin/bash
    else
        if [ -f /bin/sh ]; then
            RUNNING_SHELL=/bin/sh
        fi
    fi
fi

if [ -z "$RUNNING_SHELL" ] || [ ! -f "$RUNNING_SHELL" ]; then
    printf 'Unable to determine your shell. Please set the SHELL env. var and re-run\\n' >&2
    exit 1
fi

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
THIS_FILE=$(basename "$0")
THIS_PATH="$THIS_DIR/$THIS_FILE"
PREFIX=$HOME/anaconda3
BATCH=0
FORCE=0
SKIP_SCRIPTS=0
TEST=0
REINSTALL=0
USAGE="
usage: $0 [options]

Installs Anaconda3 5.3.0

-b           run install in batch mode (without manual intervention),
             it is expected the license terms are agreed upon
-f           no error if install prefix already exists
-h           print this help message and exit
-p PREFIX    install prefix, defaults to $PREFIX, must not contain spaces.
-s           skip running pre/post-link/install scripts
-u           update an existing installation
-t           run package tests after installation (may install conda-build)
"

if which getopt > /dev/null 2>&1; then
    OPTS=$(getopt bfhp:sut "$*" 2>/dev/null)
    if [ ! $? ]; then
        printf "%s\\n" "$USAGE"
        exit 2
    fi

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -h)
                printf "%s\\n" "$USAGE"
                exit 2
                ;;
            -b)
                BATCH=1
                shift
                ;;
            -f)
                FORCE=1
                shift
                ;;
            -p)
                PREFIX="$2"
                shift
                shift
                ;;
            -s)
                SKIP_SCRIPTS=1
                shift
                ;;
            -u)
                FORCE=1
                shift
                ;;
            -t)
                TEST=1
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                printf "ERROR: did not recognize option '%s', please try -h\\n" "$1"
                exit 1
                ;;
        esac
    done
else
    while getopts "bfhp:sut" x; do
        case "$x" in
            h)
                printf "%s\\n" "$USAGE"
                exit 2
            ;;
            b)
                BATCH=1
                ;;
            f)
                FORCE=1
                ;;
            p)
                PREFIX="$OPTARG"
                ;;
            s)
                SKIP_SCRIPTS=1
                ;;
            u)
                FORCE=1
                ;;
            t)
                TEST=1
                ;;
            ?)
                printf "ERROR: did not recognize option '%s', please try -h\\n" "$x"
                exit 1
                ;;
        esac
    done
fi

if ! bzip2 --help >/dev/null 2>&1; then
    printf "WARNING: bzip2 does not appear to be installed this may cause problems below\\n" >&2
fi

# verify the size of the installer
if ! wc -c "$THIS_PATH" | grep    667822837 >/dev/null; then
    printf "ERROR: size of %s should be    667822837 bytes\\n" "$THIS_FILE" >&2
    exit 1
fi

if [ "$BATCH" = "0" ] # interactive mode
then
    if [ "$(uname -m)" != "x86_64" ]; then
        printf "WARNING:\\n"
        printf "    Your operating system appears not to be 64-bit, but you are trying to\\n"
        printf "    install a 64-bit version of Anaconda3.\\n"
        printf "    Are sure you want to continue the installation? [yes|no]\\n"
        printf "[no] >>> "
        read -r ans
        if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
           [ "$ans" != "y" ]   && [ "$ans" != "Y" ]
        then
            printf "Aborting installation\\n"
            exit 2
        fi
    fi
    if [ "$(uname)" != "Linux" ]; then
        printf "WARNING:\\n"
        printf "    Your operating system does not appear to be Linux, \\n"
        printf "    but you are trying to install a Linux version of Anaconda3.\\n"
        printf "    Are sure you want to continue the installation? [yes|no]\\n"
        printf "[no] >>> "
        read -r ans
        if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
           [ "$ans" != "y" ]   && [ "$ans" != "Y" ]
        then
            printf "Aborting installation\\n"
            exit 2
        fi
    fi
    printf "\\n"
    printf "Welcome to Anaconda3 5.3.0\\n"
    printf "\\n"
    printf "In order to continue the installation process, please review the license\\n"
    printf "agreement.\\n"
    printf "Please, press ENTER to continue\\n"
    printf ">>> "
    read -r dummy
    pager="cat"
    if command -v "more" > /dev/null 2>&1; then
      pager="more"
    fi
    "$pager" <<EOF
===================================
Anaconda End User License Agreement
===================================

Copyright 2015, Anaconda, Inc.

All rights reserved under the 3-clause BSD License:

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of Anaconda, Inc. ("Anaconda, Inc.") nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ANACONDA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Notice of Third Party Software Licenses
=======================================

Anaconda Distribution contains open source software packages from third parties. These are available on an "as is" basis and subject to their individual license agreements. These licenses are available in Anaconda Distribution or at http://docs.anaconda.com/anaconda/pkg-docs. Any binary packages of these third party tools you obtain via Anaconda Distribution are subject to their individual licenses as well as the Anaconda license. Anaconda, Inc. reserves the right to change which third party tools are provided in Anaconda Distribution.

In particular, Anaconda Distribution contains re-distributable, run-time, shared-library files from the Intel(TM) Math Kernel Library ("MKL binaries"). You are specifically authorized to use the MKL binaries with your installation of Anaconda Distribution. You are also authorized to redistribute the MKL binaries with Anaconda Distribution or in the conda package that contains them. Use and redistribution of the MKL binaries are subject to the licensing terms located at https://software.intel.com/en-us/license/intel-simplified-software-license. If needed, instructions for removing the MKL binaries after installation of Anaconda Distribution are available at http://www.anaconda.com.

Anaconda Distribution also contains cuDNN software binaries from NVIDIA Corporation ("cuDNN binaries"). You are specifically authorized to use the cuDNN binaries with your installation of Anaconda Distribution. You are also authorized to redistribute the cuDNN binaries with an Anaconda Distribution package that contains them. If needed, instructions for removing the cuDNN binaries after installation of Anaconda Distribution are available at http://www.anaconda.com.


Anaconda Distribution also contains Visual Studio Code software binaries from Microsoft Corporation ("VS Code"). You are specifically authorized to use VS Code with your installation of Anaconda Distribution. Use of VS Code is subject to the licensing terms located at https://code.visualstudio.com/License.

Cryptography Notice
===================

This distribution includes cryptographic software. The country in which you currently reside may have restrictions on the import, possession, use, and/or re-export to another country, of encryption software. BEFORE using any encryption software, please check your country's laws, regulations and policies concerning the import, possession, or use, and re-export of encryption software, to see if this is permitted. See the Wassenaar Arrangement http://www.wassenaar.org/ for more information.

Anaconda, Inc. has self-classified this software as Export Commodity Control Number (ECCN) 5D992b, which includes mass market information security software using or performing cryptographic functions with asymmetric algorithms. No license is required for export of this software to non-embargoed countries. In addition, the Intel(TM) Math Kernel Library contained in Anaconda, Inc.'s software is classified by Intel(TM) as ECCN 5D992b with no license required for export to non-embargoed countries and Microsoft's Visual Studio Code software is classified by Microsoft as ECCN 5D992.c with no license required for export to non-embargoed countries.

The following packages are included in this distribution that relate to cryptography:

openssl
    The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured, and Open Source toolkit implementing the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols as well as a full-strength general purpose cryptography library.

pycrypto
    A collection of both secure hash functions (such as SHA256 and RIPEMD160), and various encryption algorithms (AES, DES, RSA, ElGamal, etc.).

pyopenssl
    A thin Python wrapper around (a subset of) the OpenSSL library.

kerberos (krb5, non-Windows platforms)
    A network authentication protocol designed to provide strong authentication for client/server applications by using secret-key cryptography.

cryptography
    A Python library which exposes cryptographic recipes and primitives.

EOF
    printf "\\n"
    printf "Do you accept the license terms? [yes|no]\\n"
    printf "[no] >>> "
    read -r ans
    while [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
          [ "$ans" != "no" ]  && [ "$ans" != "No" ]  && [ "$ans" != "NO" ]
    do
        printf "Please answer 'yes' or 'no':'\\n"
        printf ">>> "
        read -r ans
    done
    if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ]
    then
        printf "The license agreement wasn't approved, aborting installation.\\n"
        exit 2
    fi
    printf "\\n"
    printf "Anaconda3 will now be installed into this location:\\n"
    printf "%s\\n" "$PREFIX"
    printf "\\n"
    printf "  - Press ENTER to confirm the location\\n"
    printf "  - Press CTRL-C to abort the installation\\n"
    printf "  - Or specify a different location below\\n"
    printf "\\n"
    printf "[%s] >>> " "$PREFIX"
    read -r user_prefix
    if [ "$user_prefix" != "" ]; then
        case "$user_prefix" in
            *\ * )
                printf "ERROR: Cannot install into directories with spaces\\n" >&2
                exit 1
                ;;
            *)
                eval PREFIX="$user_prefix"
                ;;
        esac
    fi
fi # !BATCH

case "$PREFIX" in
    *\ * )
        printf "ERROR: Cannot install into directories with spaces\\n" >&2
        exit 1
        ;;
esac

if [ "$FORCE" = "0" ] && [ -e "$PREFIX" ]; then
    printf "ERROR: File or directory already exists: '%s'\\n" "$PREFIX" >&2
    printf "If you want to update an existing installation, use the -u option.\\n" >&2
    exit 1
elif [ "$FORCE" = "1" ] && [ -e "$PREFIX" ]; then
    REINSTALL=1
fi


if ! mkdir -p "$PREFIX"; then
    printf "ERROR: Could not create directory: '%s'\\n" "$PREFIX" >&2
    exit 1
fi

PREFIX=$(cd "$PREFIX"; pwd)
export PREFIX

printf "PREFIX=%s\\n" "$PREFIX"

# verify the MD5 sum of the tarball appended to this header
MD5=$(tail -n +810 "$THIS_PATH" | md5sum -)
if ! echo "$MD5" | grep fc8a64e5937c4b0afd9e0ecb34155ce6 >/dev/null; then
    printf "WARNING: md5sum mismatch of tar archive\\n" >&2
    printf "expected: fc8a64e5937c4b0afd9e0ecb34155ce6\\n" >&2
    printf "     got: %s\\n" "$MD5" >&2
fi

# extract the tarball appended to this header, this creates the *.tar.bz2 files
# for all the packages which get installed below
cd "$PREFIX"


if ! tail -n +810 "$THIS_PATH" | tar xf -; then
    printf "ERROR: could not extract tar starting at line 810\\n" >&2
    exit 1
fi

PRECONDA="$PREFIX/preconda.tar.bz2"
bunzip2 -c $PRECONDA | tar -xf - --no-same-owner || exit 1
rm -f $PRECONDA

PYTHON="$PREFIX/bin/python"
MSGS="$PREFIX/.messages.txt"
touch "$MSGS"
export FORCE

install_dist()
{
    # This function installs a conda package into prefix, but without linking
    # the conda packages.  It untars the package and calls a simple script
    # which does the post extract steps (update prefix files, run 'post-link',
    # and creates the conda metadata).  Note that this is all done without
    # conda.
    if [ "$REINSTALL" = "1" ]; then
      printf "reinstalling: %s ...\\n" "$1"
    else
      printf "installing: %s ...\\n" "$1"
    fi
    PKG_PATH="$PREFIX"/pkgs/$1
    PKG="$PKG_PATH".tar.bz2
    mkdir -p $PKG_PATH || exit 1
    bunzip2 -c "$PKG" | tar -xf - -C "$PKG_PATH" --no-same-owner || exit 1
    "$PREFIX/pkgs/python-3.7.0-hc3d631a_0/bin/python" -E -s \
        "$PREFIX"/pkgs/.install.py $INST_OPT --root-prefix="$PREFIX" --link-dist="$1" || exit 1
    if [ "$1" = "python-3.7.0-hc3d631a_0" ]; then
        if ! "$PYTHON" -E -V; then
            printf "ERROR:\\n" >&2
            printf "cannot execute native linux-64 binary, output from 'uname -a' is:\\n" >&2
            uname -a >&2
            exit 1
        fi
    fi
}

install_dist python-3.7.0-hc3d631a_0
install_dist blas-1.0-mkl
install_dist ca-certificates-2018.03.07-0
install_dist conda-env-2.6.0-1
install_dist intel-openmp-2019.0-118
install_dist libgcc-ng-8.2.0-hdf63c60_1
install_dist libgfortran-ng-7.3.0-hdf63c60_0
install_dist libstdcxx-ng-8.2.0-hdf63c60_1
install_dist bzip2-1.0.6-h14c3975_5
install_dist expat-2.2.6-he6710b0_0
install_dist fribidi-1.0.5-h7b6447c_0
install_dist gmp-6.1.2-h6c8ec71_1
install_dist graphite2-1.3.12-h23475e2_2
install_dist icu-58.2-h9c2bf20_1
install_dist jbig-2.1-hdba287a_0
install_dist jpeg-9b-h024ee3a_2
install_dist libffi-3.2.1-hd88cf55_4
install_dist libsodium-1.0.16-h1bed415_0
install_dist libtool-2.4.6-h544aabb_3
install_dist libuuid-1.0.3-h1bed415_2
install_dist libxcb-1.13-h1bed415_1
install_dist lzo-2.10-h49e0be7_2
install_dist mkl-2019.0-118
install_dist ncurses-6.1-hf484d3e_0
install_dist openssl-1.0.2p-h14c3975_0
install_dist patchelf-0.9-hf484d3e_2
install_dist pcre-8.42-h439df22_0
install_dist pixman-0.34.0-hceecf20_3
install_dist snappy-1.1.7-hbae5bb6_3
install_dist xz-5.2.4-h14c3975_4
install_dist yaml-0.1.7-had09818_2
install_dist zlib-1.2.11-ha838bed_2
install_dist blosc-1.14.4-hdbcaa40_0
install_dist glib-2.56.2-hd408876_0
install_dist hdf5-1.10.2-hba1933b_1
install_dist libedit-3.1.20170329-h6b74fdf_2
install_dist libpng-1.6.34-hb9fc6fc_0
install_dist libssh2-1.8.0-h9cfc8f7_4
install_dist libtiff-4.0.9-he85c1e1_2
install_dist libxml2-2.9.8-h26e45fe_1
install_dist mpfr-4.0.1-hdf1c602_3
install_dist pandoc-1.19.2.1-hea2e7c5_1
install_dist readline-7.0-h7b6447c_5
install_dist tk-8.6.8-hbc83047_0
install_dist zeromq-4.2.5-hf484d3e_1
install_dist dbus-1.13.2-h714fa37_1
install_dist freetype-2.9.1-h8a8886c_1
install_dist gstreamer-1.14.0-hb453b48_1
install_dist libcurl-7.61.0-h1ad7b7a_0
install_dist libxslt-1.1.32-h1312cb7_0
install_dist mpc-1.1.0-h10f8cd9_1
install_dist sqlite-3.24.0-h84994c4_0
install_dist unixodbc-2.3.7-h14c3975_0
install_dist curl-7.61.0-h84994c4_0
install_dist fontconfig-2.13.0-h9420a91_0
install_dist gst-plugins-base-1.14.0-hbbd80ab_1
install_dist alabaster-0.7.11-py37_0
install_dist appdirs-1.4.3-py37h28b3542_0
install_dist asn1crypto-0.24.0-py37_0
install_dist atomicwrites-1.2.1-py37_0
install_dist attrs-18.2.0-py37h28b3542_0
install_dist backcall-0.1.0-py37_0
install_dist backports-1.0-py37_1
install_dist beautifulsoup4-4.6.3-py37_0
install_dist bitarray-0.8.3-py37h14c3975_0
install_dist boto-2.49.0-py37_0
install_dist cairo-1.14.12-h8948797_3
install_dist certifi-2018.8.24-py37_1
install_dist chardet-3.0.4-py37_1
install_dist click-6.7-py37_0
install_dist cloudpickle-0.5.5-py37_0
install_dist colorama-0.3.9-py37_0
install_dist constantly-15.1.0-py37h28b3542_0
install_dist contextlib2-0.5.5-py37_0
install_dist dask-core-0.19.1-py37_0
install_dist decorator-4.3.0-py37_0
install_dist defusedxml-0.5.0-py37_1
install_dist docutils-0.14-py37_0
install_dist entrypoints-0.2.3-py37_2
install_dist et_xmlfile-1.0.1-py37_0
install_dist fastcache-1.0.2-py37h14c3975_2
install_dist filelock-3.0.8-py37_0
install_dist glob2-0.6-py37_0
install_dist gmpy2-2.0.8-py37h10f8cd9_2
install_dist greenlet-0.4.15-py37h7b6447c_0
install_dist heapdict-1.0.0-py37_2
install_dist idna-2.7-py37_0
install_dist imagesize-1.1.0-py37_0
install_dist incremental-17.5.0-py37_0
install_dist ipython_genutils-0.2.0-py37_0
install_dist itsdangerous-0.24-py37_1
install_dist jdcal-1.4-py37_0
install_dist jeepney-0.3.1-py37_0
install_dist kiwisolver-1.0.1-py37hf484d3e_0
install_dist lazy-object-proxy-1.3.1-py37h14c3975_2
install_dist llvmlite-0.24.0-py37hdbcaa40_0
install_dist locket-0.2.0-py37_1
install_dist lxml-4.2.5-py37hefd8a0e_0
install_dist markupsafe-1.0-py37h14c3975_1
install_dist mccabe-0.6.1-py37_1
install_dist mistune-0.8.3-py37h14c3975_1
install_dist mkl-service-1.1.2-py37h90e4bf4_5
install_dist mpmath-1.0.0-py37_2
install_dist msgpack-python-0.5.6-py37h6bb024c_1
install_dist numpy-base-1.15.1-py37h81de0dd_0
install_dist olefile-0.46-py37_0
install_dist pandocfilters-1.4.2-py37_1
install_dist parso-0.3.1-py37_0
install_dist path.py-11.1.0-py37_0
install_dist pep8-1.7.1-py37_0
install_dist pickleshare-0.7.4-py37_0
install_dist pkginfo-1.4.2-py37_1
install_dist pluggy-0.7.1-py37h28b3542_0
install_dist ply-3.11-py37_0
install_dist psutil-5.4.7-py37h14c3975_0
install_dist ptyprocess-0.6.0-py37_0
install_dist py-1.6.0-py37_0
install_dist pyasn1-0.4.4-py37h28b3542_0
install_dist pycodestyle-2.4.0-py37_0
install_dist pycosat-0.6.3-py37h14c3975_0
install_dist pycparser-2.18-py37_1
install_dist pycrypto-2.6.1-py37h14c3975_9
install_dist pycurl-7.43.0.2-py37hb7f436b_0
install_dist pyflakes-2.0.0-py37_0
install_dist pyodbc-4.0.24-py37he6710b0_0
install_dist pyparsing-2.2.0-py37_1
install_dist pysocks-1.6.8-py37_0
install_dist pytz-2018.5-py37_0
install_dist pyyaml-3.13-py37h14c3975_0
install_dist pyzmq-17.1.2-py37h14c3975_0
install_dist qt-5.9.6-h8703b6f_2
install_dist qtpy-1.5.0-py37_0
install_dist rope-0.11.0-py37_0
install_dist ruamel_yaml-0.15.46-py37h14c3975_0
install_dist send2trash-1.5.0-py37_0
install_dist simplegeneric-0.8.1-py37_2
install_dist sip-4.19.8-py37hf484d3e_0
install_dist six-1.11.0-py37_1
install_dist snowballstemmer-1.2.1-py37_0
install_dist sortedcontainers-2.0.5-py37_0
install_dist sphinxcontrib-1.0-py37_1
install_dist sqlalchemy-1.2.11-py37h7b6447c_0
install_dist tblib-1.3.2-py37_0
install_dist testpath-0.3.1-py37_0
install_dist toolz-0.9.0-py37_0
install_dist tornado-5.1-py37h14c3975_0
install_dist tqdm-4.26.0-py37h28b3542_0
install_dist unicodecsv-0.14.1-py37_0
install_dist wcwidth-0.1.7-py37_0
install_dist webencodings-0.5.1-py37_1
install_dist werkzeug-0.14.1-py37_0
install_dist wrapt-1.10.11-py37h14c3975_2
install_dist xlrd-1.1.0-py37_1
install_dist xlsxwriter-1.1.0-py37_0
install_dist xlwt-1.3.0-py37_0
install_dist zope-1.0-py37_1
install_dist astroid-2.0.4-py37_0
install_dist automat-0.7.0-py37_0
install_dist babel-2.6.0-py37_0
install_dist backports.shutil_get_terminal_size-1.0.0-py37_2
install_dist cffi-1.11.5-py37he75722e_1
install_dist cycler-0.10.0-py37_0
install_dist cytoolz-0.9.0.1-py37h14c3975_1
install_dist harfbuzz-1.8.8-hffaf4a1_0
install_dist html5lib-1.0.1-py37_0
install_dist hyperlink-18.0.0-py37_0
install_dist jedi-0.12.1-py37_0
install_dist more-itertools-4.3.0-py37_0
install_dist multipledispatch-0.6.0-py37_0
install_dist networkx-2.1-py37_0
install_dist nltk-3.3.0-py37_0
install_dist openpyxl-2.5.6-py37_0
install_dist packaging-17.1-py37_0
install_dist partd-0.3.8-py37_0
install_dist pathlib2-2.3.2-py37_0
install_dist pexpect-4.6.0-py37_0
install_dist pillow-5.2.0-py37heded4f4_0
install_dist pyasn1-modules-0.2.2-py37_0
install_dist pyqt-5.9.2-py37h05f1152_2
install_dist python-dateutil-2.7.3-py37_0
install_dist qtawesome-0.4.4-py37_0
install_dist setuptools-40.2.0-py37_0
install_dist singledispatch-3.4.0.3-py37_0
install_dist sortedcollections-1.0.1-py37_0
install_dist sphinxcontrib-websupport-1.1.0-py37_1
install_dist sympy-1.2-py37_0
install_dist terminado-0.8.1-py37_1
install_dist traitlets-4.3.2-py37_0
install_dist zict-0.1.3-py37_0
install_dist zope.interface-4.5.0-py37h14c3975_0
install_dist bleach-2.1.4-py37_0
install_dist clyent-1.2.2-py37_1
install_dist cryptography-2.3.1-py37hc365091_0
install_dist cython-0.28.5-py37hf484d3e_0
install_dist distributed-1.23.1-py37_0
install_dist get_terminal_size-1.0.0-haa9412d_0
install_dist gevent-1.3.6-py37h7b6447c_0
install_dist isort-4.3.4-py37_0
install_dist jinja2-2.10-py37_0
install_dist jsonschema-2.6.0-py37_0
install_dist jupyter_core-4.4.0-py37_0
install_dist navigator-updater-0.2.1-py37_0
install_dist nose-1.3.7-py37_2
install_dist pango-1.42.4-h049681c_0
install_dist pygments-2.2.0-py37_0
install_dist pytest-3.8.0-py37_0
install_dist wheel-0.31.1-py37_0
install_dist flask-1.0.2-py37_1
install_dist jupyter_client-5.2.3-py37_0
install_dist nbformat-4.4.0-py37_0
install_dist pip-10.0.1-py37_0
install_dist prompt_toolkit-1.0.15-py37_0
install_dist pylint-2.1.1-py37_0
install_dist pyopenssl-18.0.0-py37_0
install_dist pytest-openfiles-0.3.0-py37_0
install_dist pytest-remotedata-0.3.0-py37_0
install_dist secretstorage-3.1.0-py37_0
install_dist flask-cors-3.0.6-py37_0
install_dist ipython-6.5.0-py37_0
install_dist keyring-13.2.1-py37_0
install_dist nbconvert-5.4.0-py37_1
install_dist service_identity-17.0.0-py37h28b3542_0
install_dist urllib3-1.23-py37_0
install_dist ipykernel-4.9.0-py37_1
install_dist requests-2.19.1-py37_0
install_dist twisted-18.7.0-py37h14c3975_1
install_dist anaconda-client-1.7.2-py37_0
install_dist jupyter_console-5.2.0-py37_1
install_dist prometheus_client-0.3.1-py37h28b3542_0
install_dist qtconsole-4.4.1-py37_0
install_dist sphinx-1.7.9-py37_0
install_dist spyder-kernels-0.2.6-py37_0
install_dist anaconda-navigator-1.9.2-py37_0
install_dist anaconda-project-0.8.2-py37_0
install_dist notebook-5.6.0-py37_0
install_dist numpydoc-0.8.0-py37_0
install_dist jupyterlab_launcher-0.13.1-py37_0
install_dist spyder-3.3.1-py37_1
install_dist widgetsnbextension-3.4.1-py37_0
install_dist ipywidgets-7.4.1-py37_0
install_dist jupyterlab-0.34.9-py37_0
install_dist _ipyw_jlab_nb_ext_conf-0.1.0-py37_0
install_dist jupyter-1.0.0-py37_7
install_dist bokeh-0.13.0-py37_0
install_dist bottleneck-1.2.1-py37h035aef0_1
install_dist conda-4.5.11-py37_0
install_dist conda-build-3.15.1-py37_0
install_dist datashape-0.5.4-py37_1
install_dist h5py-2.8.0-py37h989c5e5_3
install_dist imageio-2.4.1-py37_0
install_dist matplotlib-2.2.3-py37hb69df0a_0
install_dist mkl_fft-1.0.4-py37h4414c95_1
install_dist mkl_random-1.0.1-py37h4414c95_1
install_dist numpy-1.15.1-py37h1d66e8a_0
install_dist numba-0.39.0-py37h04863e7_0
install_dist numexpr-2.6.8-py37hd89afb7_0
install_dist pandas-0.23.4-py37h04863e7_0
install_dist pytest-arraydiff-0.2-py37h39e3cac_0
install_dist pytest-doctestplus-0.1.3-py37_0
install_dist pywavelets-1.0.0-py37hdd07704_0
install_dist scipy-1.1.0-py37hfa4b5c9_1
install_dist bkcharts-0.2-py37_0
install_dist dask-0.19.1-py37_0
install_dist patsy-0.5.0-py37_0
install_dist pytables-3.4.4-py37ha205bf6_0
install_dist pytest-astropy-0.4.0-py37_0
install_dist scikit-image-0.14.0-py37hf484d3e_1
install_dist scikit-learn-0.19.2-py37h4989274_0
install_dist astropy-3.0.4-py37h14c3975_0
install_dist odo-0.5.1-py37_0
install_dist statsmodels-0.9.0-py37h035aef0_0
install_dist blaze-0.11.3-py37_0
install_dist seaborn-0.9.0-py37_0
install_dist anaconda-5.3.0-py37_0


mkdir -p $PREFIX/envs

if [ "$FORCE" = "1" ]; then
    "$PYTHON" -E -s "$PREFIX"/pkgs/.install.py --rm-dup || exit 1
fi

cat "$MSGS"
rm -f "$MSGS"
$PYTHON -E -s "$PREFIX/pkgs/.cio-config.py" "$THIS_PATH" || exit 1
printf "installation finished.\\n"

if [ "$PYTHONPATH" != "" ]; then
    printf "WARNING:\\n"
    printf "    You currently have a PYTHONPATH environment variable set. This may cause\\n"
    printf "    unexpected behavior when running the Python interpreter in Anaconda3.\\n"
    printf "    For best results, please verify that your PYTHONPATH only points to\\n"
    printf "    directories of packages that are compatible with the Python interpreter\\n"
    printf "    in Anaconda3: $PREFIX\\n"
fi

if [ "$BATCH" = "0" ]; then
    # Interactive mode.
    BASH_RC="$HOME"/.bashrc
    DEFAULT=no
    printf "Do you wish the installer to initialize Anaconda3\\n"
    printf "in your %s ? [yes|no]\\n" "$BASH_RC"
    printf "[%s] >>> " "$DEFAULT"
    read -r ans
    if [ "$ans" = "" ]; then
        ans=$DEFAULT
    fi
    if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
       [ "$ans" != "y" ]   && [ "$ans" != "Y" ]
    then
        printf "\\n"
        printf "You may wish to edit your $BASH_RC to setup Anaconda3:\\n"
        printf "\\n"
        if [ -f "$PREFIX/etc/profile.d/conda.sh" ]; then
            printf "source $PREFIX/etc/profile.d/conda.sh\\n"
        else
            printf "export PATH=\"$PREFIX/bin:\$PATH\"\\n"
        fi
        printf "\\n"
    else
        if [ -f "$BASH_RC" ]; then
            printf "\\n"
            printf "Initializing Anaconda3 in %s\\n" "$BASH_RC"
            printf "A backup will be made to: %s-anaconda3.bak\\n" "$BASH_RC"
            printf "\\n"
            cp "$BASH_RC" "${BASH_RC}"-anaconda3.bak
        else
            printf "\\n"
            printf "Initializing Anaconda3 in newly created %s\\n" "$BASH_RC"
        fi
        cat <<EOF >> "$BASH_RC"
# added by Anaconda3 5.3.0 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="\$(CONDA_REPORT_ERRORS=false '$PREFIX/bin/conda' shell.bash hook 2> /dev/null)"
if [ \$? -eq 0 ]; then
    \\eval "\$__conda_setup"
else
    if [ -f "$PREFIX/etc/profile.d/conda.sh" ]; then
        . "$PREFIX/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \\export PATH="$PREFIX/bin:\$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<
EOF
        printf "\\n"
        printf "For this change to become active, you have to open a new terminal.\\n"
        printf "\\n"
    fi

    printf "Thank you for installing Anaconda3!\\n"
fi # !BATCH

if [ "$TEST" = "1" ]; then
    printf "INFO: Running package tests in a subshell\\n"
    (. "$PREFIX"/bin/activate
     which conda-build > /dev/null 2>&1 || conda install -y conda-build
     if [ ! -d "$PREFIX"/conda-bld/linux-64 ]; then
         mkdir -p "$PREFIX"/conda-bld/linux-64
     fi
     cp -f "$PREFIX"/pkgs/*.tar.bz2 "$PREFIX"/conda-bld/linux-64/
     conda index "$PREFIX"/conda-bld/linux-64/
     conda-build --override-channels --channel local --test --keep-going "$PREFIX"/conda-bld/linux-64/*.tar.bz2
    )
    NFAILS=$?
    if [ "$NFAILS" != "0" ]; then
        if [ "$NFAILS" = "1" ]; then
            printf "ERROR: 1 test failed\\n" >&2
            printf "To re-run the tests for the above failed package, please enter:\\n"
            printf ". %s/bin/activate\\n" "$PREFIX"
            printf "conda-build --override-channels --channel local --test <full-path-to-failed.tar.bz2>\\n"
        else
            printf "ERROR: %s test failed\\n" $NFAILS >&2
            printf "To re-run the tests for the above failed packages, please enter:\\n"
            printf ". %s/bin/activate\\n" "$PREFIX"
            printf "conda-build --override-channels --channel local --test <full-path-to-failed.tar.bz2>\\n"
        fi
        exit $NFAILS
    fi
fi

if [ "$BATCH" = "0" ]; then
    $PYTHON -E -s "$PREFIX/pkgs/vscode_inst.py" --is-supported
    if [ "$?" = "0" ]; then
