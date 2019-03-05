#!/bin/bash
set -xe

name=vim
version=8.1.0994
url=https://github.com/vim/vim/archive/v${version}.tar.gz

curl -LO ${url}
tar xf v${version}.tar.gz

pushd ${name}-${version}/src
    ./configure --prefix=${TOOLCHAIN} \
        --without-local-dir \
        --enable-cscope \
        --enable-multibyte \
        --enable-python3interp=dynamic

    make -j${_maxjobs}
    make install STRIP=strip
popd

rm -f v${version}*.tar.gz
rm -rf ${name}-${version}
