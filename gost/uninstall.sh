#!/bin/sh

sh /koolshare/scripts/gost_config.sh stop >/dev/null 2>&1

rm /koolshare/res/icon-gost.png >/dev/null 2>&1
rm /koolshare/scripts/gost* >/dev/null 2>&1
rm /koolshare/scripts/uninstall_gost.sh >/dev/null 2>&1
rm /koolshare/webs/Module_gost.asp >/dev/null 2>&1
rm /koolshare/configs/${module}.yaml >/dev/null 2>&1
rm -rf /koolshare/init.d/*gost.sh >/dev/null 2>&1