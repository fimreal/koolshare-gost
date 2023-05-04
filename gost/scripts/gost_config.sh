#!/bin/sh
app_name="gost"

source /koolshare/scripts/base.sh
eval $(dbus export ${app_name})
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

gost_config="/koolshare/configs/${app_name}.yaml"
# touch $gost_config

# ====================================函数定义====================================
get_config_file() {
    # 获取单个文件的内容
    if [ ! -f ${gost_config} ]; then
        echo_date "文件没找到: ${gost_config}"
        return 1
    fi
    dbus set gost_config_content=$(base64 ${gost_config})
    if [ $? -ne 0 ]; then
        echo_date "${gost_config} 文件读取失败!"
        return 2
    fi
    echo_date "${gost_config} 文件读取完成!"
}

set_config_file() {
    if [ ! -f ${gost_config} ]; then
        echo_date "文件没找到: ${gost_config}"
        return 1
    fi
    cp ${gost_config} ${gost_config}.bak
    echo -n ${gost_config_content} | base64 -d >${gost_config}.tmp
    if [ $? -eq 0 ]; then
        mv ${gost_config}.tmp ${gost_config}
        rm -f ${gost_config}.bak
        echo_date "${gost_config} 保存成功!"
    else
        rm -f ${gost_config}.bak
        echo_date "${gost_config} 保存失败!"
        return 1
    fi
}

# 配置iptables规则
iptables_add_red() {
    if [ "$gost_red_enable" = "off" ]; then
        echo_date "透明代理模式已关闭! 不需要添加 iptables 转发规则!"
        return 0
    fi
    if iptables -t nat -S ${app_name} >/dev/null 2>&1; then
        echo_date "已经配置过 ${app_name} 的iptables规则!"
        return 0
    fi

    # 路由器IP地址
    lan_ipaddr="$(nvram get lan_ipaddr)"

    echo_date "开始配置 ${app_name} iptables规则..."

    # 创建 ipset 规则
    ipset create gost hash:ip >/dev/null 2>&1

    # 创建新表
    iptables -t nat -N ${app_name}
    iptables -t nat -F ${app_name}
    iptables -t nat -A PREROUTING -p tcp -s ${lan_ipaddr}/24 -j ${app_name}

    # 内部地址请求不转发
    iptables -t nat -A ${app_name} -d 10.0.0.0/8 -j RETURN
    iptables -t nat -A ${app_name} -d 127.0.0.0/8 -j RETURN
    iptables -t nat -A ${app_name} -d 169.254.0.0/16 -j RETURN
    iptables -t nat -A ${app_name} -d 172.16.0.0/12 -j RETURN
    iptables -t nat -A ${app_name} -d ${lan_ipaddr}/24 -j RETURN

    # 按照 ipset 规则转发到 gost
    iptables -t nat -A ${app_name} -s ${lan_ipaddr}/24 -p tcp -m set --match-set gost dst -j REDIRECT --to-ports ${gost_redport:-12345}

}

# 清理iptables规则
iptables_del_red() {
    if ! iptables -t nat -S ${app_name} >/dev/null 2>&1; then
        echo_date "已经清理过 ${app_name} 的iptables规则!"
        return 0
    fi
    # 路由器IP地址
    lan_ipaddr="$(nvram get lan_ipaddr)"

    echo_date "开始清理 ${app_name} iptables 转发规则 ..."

    # 同时删除 ipset 规则
    ipset destroy gost
    
    # 删除 iptables 规则
    iptables -t nat -D PREROUTING -p tcp -s ${lan_ipaddr}/24 -j ${app_name} 2>/dev/null
    iptables -t nat -X ${app_name} 2>/dev/null
}

# 启动服务
service_start() {
    nohup ${app_name} -C ${gost_config} >/dev/null 2>&1 &
    sleep 3
    if pidof ${app_name} >/dev/null 2>&1; then
        echo_date "${CMD} 启动成功!"
        echo_date "${app_name} 服务启动成功 : pid=$(pidof ${app_name})"
        dbus set ${app_name}_enable="1"
        dbus set ${app_name}_run_status="$(pidof ${app_name})"
    else
        echo_date "${CMD} 启动失败!"
        dbus set ${app_name}_run_status=""
        return 1
    fi
    iptables_add_red
}

service_stop() {
    # 1. 停止服务进程
    # 2. 清理iptables策略
    if pidof ${app_name} >/dev/null 2>&1; then
        echo_date "开始停止 ${app_name} ..."
        killall ${app_name}
    fi
    # del_iptables 2>/dev/null
    if pidof ${app_name} >/dev/null 2>&1; then
        echo_date "${CMD} 停止失败!"
        dbus set ${app_name}_enable="1"
    else
        echo_date "${CMD} 停止成功!"
        dbus set ${app_name}_enable="0"
        dbus set ${app_name}_run_status=""
    fi
    iptables_del_red
}

usage() {
    cat <<END
 ======================================================
 使用帮助:
    ${app_name} <start|stop|restart>

 参数介绍:
    start   启动服务
    stop    停止服务
    restart 重启服务

 ======================================================
END
    exit 0
}

# =================================used by init or cru=================================
case $1 in
start)
    #此处为开机自启动设计
    logger "[软件中心]: 启动gost！"
    service_start
    get_config_file
    # logger "[软件中心]: gost 未设置开机启动，跳过！"
    ;;
stop | kill)
    #此处卸载插件时关闭插件设计
    service_stop
    ;;
get_config_file)
    # 获取配置文件内容（base64）
    get_config_file
    ;;
restart)
    # 重启
    service_stop
    service_start
    ;;
esac

# ====================================submit by web====================================
case $2 in
1)
    if [ "${gost_enable}" == "1" ]; then
        [ ! -L "/koolshare/init.d/S99gost.sh" ] && ln -sf /koolshare/scripts/gost_config.sh /koolshare/init.d/S99gost.sh
        set_config_file
    else
        service_stop
    fi
    # 返回 web 传入随机 int，显示脚本执行完毕
    http_response "$1"
    ;;
2)
    # arg = 2，重启服务
    if [ "${gost_enable}" == "1" ]; then
        [ ! -L "/koolshare/init.d/S99gost.sh" ] && ln -sf /koolshare/scripts/gost_config.sh /koolshare/init.d/S99gost.sh
        service_stop
        service_start
    fi
    # 返回 web 传入随机 int，显示脚本执行完毕
    http_response "$1"
    ;;
esac