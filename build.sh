#!/bin/sh

# build script for rogsoft project

MODULE="gost"
VERSION="0.2"
TITLE="gost"
DESCRIPTION="gost"
HOME_URL="Module_gost.asp"
TAGS="代理转发服务"
AUTHOR="fimreal"
ARCH=linux_armv7    # AC86U

# Check and include base
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# clean old package
. $DIR/clean.sh

# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here
set -e

assest_url=$(
    curl -sL 'https://api.github.com/repos/go-gost/gost/releases?per_page=1' | \
    awk -F\" -v ARCH="${ARCH}" '/http/{if($0 ~ ARCH) print $(NF-1)}'
)
echo download: ${assest_url}

# use proxy
# curl -L https://cfdown.2fw.top/${assest_url} -o gostbin.tgz
curl -L ${assest_url} -o gostbin.tgz

tar xf gostbin.tgz -C gost/bin/ gost

rm gostbin.tgz

do_build_result
