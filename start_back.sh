#!/bin/bash

#################### 脚本初始化任务 ####################

# 获取脚本工作目录绝对路径
export Server_Dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# 加载.env变量文件（如果存在，用于获取 SECRET 等）
[ -f $Server_Dir/.env ] && source $Server_Dir/.env

# 给二进制启动程序添加可执行权限
chmod +x $Server_Dir/bin/*
chmod +x $Server_Dir/scripts/*

#################### 变量设置 ####################

Conf_Dir="$Server_Dir/conf"
# 使用备份目录作为配置来源
Back_Temp_Dir="$Server_Dir/temp.bak"
Log_Dir="$Server_Dir/logs"

# 获取 CLASH_SECRET 值，如果不存在则生成一个随机数
Secret=${CLASH_SECRET:-$(openssl rand -hex 32)}

#################### 函数定义 ####################

success() {
	echo -en "\033[60G[\033[1;32m  OK  \033[0;39m]\r"
	return 0
}

failure() {
	local rc=$?
	echo -en "\033[60G[\033[1;31mFAILED\033[0;39m]\r"
	return $rc
}

if_success() {
	local STRING=$1
	local ReturnStatus=$3
	if [ $ReturnStatus -eq 0 ]; then
		echo -n "$STRING "
		success
	else
		echo -n "$STRING "
		failure
		exit 1
	fi
	echo
}

#################### 任务执行 ####################

## 检查备份配置文件是否存在
echo -e '正在检查备份配置文件...'
if [ ! -f "$Back_Temp_Dir/clash_config.yaml" ] && [ ! -f "$Back_Temp_Dir/clash.yaml" ]; then
    echo -e "\033[31m[ERROR] 在 $Back_Temp_Dir 中未找到 clash_config.yaml 或 clash.yaml！\033[0m"
    exit 1
fi

## 准备配置文件
echo -e '正在从备份目录准备配置文件...'

# 确定源文件
if [ -f "$Back_Temp_Dir/clash_config.yaml" ]; then
    Source_File="$Back_Temp_Dir/clash_config.yaml"
else
    Source_File="$Back_Temp_Dir/clash.yaml"
fi

# 提取代理配置并合并（逻辑同 start.sh）
sed -n '/^proxies:/,$p' "$Source_File" > "$Back_Temp_Dir/proxy.txt"
cat "$Back_Temp_Dir/templete_config.yaml" > "$Back_Temp_Dir/config.yaml"
cat "$Back_Temp_Dir/proxy.txt" >> "$Back_Temp_Dir/config.yaml"

# 复制到正式配置目录
\cp "$Back_Temp_Dir/config.yaml" "$Conf_Dir/"

# 配置 Dashboard 路径及 Secret
Dashboard_Dir="${Server_Dir}/dashboard/public"
sed -ri "s@^# external-ui:.*@external-ui: ${Dashboard_Dir}@g" "$Conf_Dir/config.yaml"
sed -r -i '/^secret: /s@(secret: ).*@\1'${Secret}'@g' "$Conf_Dir/config.yaml"

## 获取CPU架构信息
source $Server_Dir/scripts/get_cpu_arch.sh

## 启动Clash服务
echo -e '\n正在启动Clash服务 (使用本地备份配置)...'
Text5="服务启动成功！"
Text6="服务启动失败！"

case "$CpuArch" in
    *x86_64*|*amd64*)  Cmd="$Server_Dir/bin/clash-linux-amd64" ;;
    *aarch64*|*arm64*) Cmd="$Server_Dir/bin/clash-linux-arm64" ;;
    *armv7*)           Cmd="$Server_Dir/bin/clash-linux-armv7" ;;
    *loongarch64*)    Cmd="$Server_Dir/bin/clash-linux-loong64" ;;
    *) echo -e "\033[31m[ERROR] 不支持的架构: $CpuArch\033[0m"; exit 1 ;;
esac

nohup $Cmd -d $Conf_Dir &> $Log_Dir/clash.log &
if_success "$Text5" "" $?

echo -e "\nClash 已通过备份配置启动。"
echo -e "Dashboard: http://<ip>:9090/ui"
echo -e "Secret: ${Secret}\n"