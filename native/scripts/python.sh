. "$NATIVE/scripts/common.sh"

version="2.7.2"

B="$BUILD/Python-$version"

unpack () {
    pushd "$BUILD"

    tar xaf "$SOURCE/Python-$version.tgz"

    popd
}


hostbuild () {
    pushd "$BUILD/Python-$version"


    cp "$SOURCE/python-Setup" "Modules/Setup"

    ./configure --prefix="$INSTALLDIR"
    make
    make install
    cp -a Parser/pgen "$INSTALLDIR/bin/pgen"

    popd
}


apply_patches () {
    pushd "$B"

    patch -p1 < "$NATIVE/patches/python/Python-${version}-xcompile.patch"
    patch -p1 < "$NATIVE/patches/python/disable-modules.patch"
    patch -p1 < "$NATIVE/patches/python/fix-locale.patch"
    patch -p1 < "$NATIVE/patches/python/fix-gethostbyaddr.patch"
    patch -p1 < "$NATIVE/patches/python/fix-setup-flags.patch"
    patch -p1 < "$NATIVE/patches/python/fix-filesystemdefaultencoding.patch"
    patch -p1 < "$NATIVE/patches/python/fix-termios.patch"
    patch -p1 < "$NATIVE/patches/python/custom-loader.patch"
    patch -p1 < "$NATIVE/patches/python/verbose-compilation.patch"
    patch -p1 < "$NATIVE/patches/python/fix-remove-corefoundation.patch"
    patch -p1 < "$NATIVE/patches/python/fix-dynamic-lookup.patch"
    patch -p1 < "$NATIVE/patches/python/fix-dlfcn.patch"

    # Bugfix required to deal with corrupt APKs produced by the
    # Amazon App Store.
    patch -p1 < "$NATIVE/patches/python/fix-zipfile-extra.patch"

    popd
}


build () {

    pushd "$B"

    activate_toolchain

    cp "$SOURCE/python-Setup" "Modules/Setup"
    cp "$NATIVE/install/host/bin/python" hostpython
    cp "$NATIVE/install/host/bin/pgen" hostpgen

    ./configure --host=$GCC_ARCH \
        --prefix="$INSTALLDIR" \
        --enable-shared \
        --disable-toolbox-glue \
        --disable-framework

    mkdir -p Lib/plat-linux4

    make HOSTPYTHON="$B/hostpython" HOSTPGEN="$B/hostpgen" CROSS_COMPILE_TARGET=yes INSTSONAME=libpython2.7.so || true
    make install HOSTPYTHON="$B/hostpython" HOSTPGEN="$B/hostpgen" CROSS_COMPILE_TARGET=yes INSTSONAME=libpython2.7.so

    cp hostpython "$INSTALLDIR/bin"

    # reduce python
    rm -rf "$INSTALLDIR/lib/python2.7/test"
    rm -rf "$INSTALLDIR/lib/python2.7/json/tests"
    rm -rf "$INSTALLDIR/lib/python2.7/lib-tk"
    rm -rf "$INSTALLDIR/lib/python2.7/sqlite3/test"
    rm -rf "$INSTALLDIR/lib/python2.7/unittest/test"
    rm -rf "$INSTALLDIR/lib/python2.7/lib2to3/tests"
    rm -rf "$INSTALLDIR/lib/python2.7/bsddb/tests"
    rm -rf "$INSTALLDIR/lib/python2.7/distutils/tests"
    rm -rf "$INSTALLDIR/lib/python2.7/email/test"
    rm -rf "$INSTALLDIR/lib/python2.7/curses"

    popd
}


"$1"
