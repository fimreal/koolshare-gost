#!/bin/sh

# build script for rogsoft project

MODULE="gost"
VERSION="0.1"
TITLE="gost"
DESCRIPTION="gost"
HOME_URL="Module_gost.asp"
TAGS="代理转发服务"
AUTHOR="fimreal"

# Check and include base
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here
do_build_result
