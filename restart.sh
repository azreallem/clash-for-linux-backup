#!/bin/bash

#################### 脚本初始化任务 ####################

# 获取脚本工作目录绝对路径
export Server_Dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# 加载.env变量文件
[ -f $Server_Dir/.env ] && source $Server_Dir/.env

# 给二进制启动程序、脚本等添加可执行权限
chmod +x $Server_Dir/bin/*
chmod +x $Server_Dir/scripts/*



#################### 变量设置 ####################

Conf_Dir="$Server_Dir/conf"
Log_Dir="$Server_Dir/logs"



#################### 函数定义 ####################

# 自定义action函数，实现通用action功能
success() {
	echo -en "\033[60G[\033[1;32m  OK  \033[0;39m]\r"
	return 0
}

failure() {
	local rc=$?
	echo -en "\033[60G[\033[1;31mFAILED\033[0;39m]\r"
	[ -x /bin/plymouth ] && /bin/plymouth --details
	return $rc
}

action() {
	local STRING rc

	STRING=$1
	echo -n "$STRING "
	shift
	"$@" && success $"$STRING" || failure $"$STRING"
	rc=$?
	echo
	return $rc
}

# 判断命令是否正常执行 函数
if_success() {
	local ReturnStatus=$3
	if [ $ReturnStatus -eq 0 ]; then
		action "$1" /bin/true
	else
		action "$2" /bin/false
		exit 1
	fi
}



#################### 任务执行 ####################

## 关闭clash服务
echo -e '正在关闭Clash服务...'
Text1="服务关闭成功！"
Text2="服务关闭失败！"

# 查询并关闭程序进程 (匹配 bin 目录下的所有 clash 进程)
PID=$(ps -ef | grep "$Server_Dir/bin/clash-linux-" | grep -v grep | awk '{print $2}')

if [ -n "$PID" ]; then
	kill -9 $PID
	ReturnStatus=$?
else
	ReturnStatus=0
fi
if_success $Text1 $Text2 $ReturnStatus

sleep 2


## 获取CPU架构信息
# Source the script to get CPU architecture
source $Server_Dir/scripts/get_cpu_arch.sh

# Check if we obtained CPU architecture
if [[ -z "$CpuArch" ]]; then
	echo "Failed to obtain CPU architecture"
	exit 1
fi


## 启动Clash服务
echo -e '\n正在重新启动Clash服务...'
Text5="服务启动成功！"
Text6="服务启动失败！"

if [[ $CpuArch =~ "x86_64" || $CpuArch =~ "amd64"  ]]; then
	nohup $Server_Dir/bin/clash-linux-amd64 -d $Conf_Dir &> $Log_Dir/clash.log &
	ReturnStatus=$?
	if_success $Text5 $Text6 $ReturnStatus
elif [[ $CpuArch =~ "aarch64" ||  $CpuArch =~ "arm64" ]]; then
	nohup $Server_Dir/bin/clash-linux-arm64 -d $Conf_Dir &> $Log_Dir/clash.log &
	ReturnStatus=$?
	if_success $Text5 $Text6 $ReturnStatus
elif [[ $CpuArch =~ "armv7" ]]; then
	nohup $Server_Dir/bin/clash-linux-armv7 -d $Conf_Dir &> $Log_Dir/clash.log &
	ReturnStatus=$?
	if_success $Text5 $Text6 $ReturnStatus
elif [[ $CpuArch =~ "loongarch64" ]]; then
	nohup $Server_Dir/bin/clash-linux-loong64 -d $Conf_Dir &> $Log_Dir/clash.log &
	ReturnStatus=$?
	if_success $Text5 $Text6 $ReturnStatus
else
	echo -e "\033[31m\n[ERROR] Unsupported CPU Architecture！\033[0m"
	exit 1
fi

echo -e "\n服务已重启！\n"