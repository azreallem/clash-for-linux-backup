[TOC]

# 项目介绍

此项目是通过使用开源项目[clash（已跑路）](https://github.com/Dreamacro/clash)作为核心程序，再结合脚本实现简单的代理功能。<br>
clash核心备份仓库[Clash-backup](https://github.com/Elegycloud/clash-for-linux-backup)

主要是为了解决我们在服务器上下载GitHub等一些国外资源速度慢的问题。

由于作者已经跑路，当前为Elegycloud进行备份，若有侵犯您的权利，请提交issues我会看到并删除仓库<br>
clash for linux 备份(备份号：202311091510)。
若喜欢本项目，请点个小星星！
<br>

# 使用须知

- 运行本项目建议使用root用户，或者使用 sudo 提权。
- 使用过程中如遇到问题，请优先查已有的 [issues](https://github.com/Elegycloud/clash-for-linux-backup/issues)。
- 在进行issues提交前，请替换提交内容中是敏感信息（例如：订阅地址）。
- 本项目是基于 [clash（已跑路）](https://github.com/Dreamacro/clash) 、[yacd](https://github.com/haishanh/yacd) 进行的配置整合，关于clash、yacd的详细配置请去原项目查看。
- 此项目不提供任何订阅信息，请自行准备Clash订阅地址。
- 运行前请手动更改`.env`文件中的`CLASH_URL`变量值，否则无法正常运行。
- 当前在RHEL系列和Debian,Kali Linux,ubuntu以及Linux系统中测试过，其他系列可能需要适当修改脚本。
- 支持 x86_64/aarch64/loongarch64 平台
- 【注意：部分带有桌面端Linux系统的需要在浏览器设置代理！否则有可能无法使用！】
- 【若系统代理无法使用，但是想要系统代理，请修改尝试修改start.sh中的端口后执行环境变量命令！】
- 【还是无法使用请更换当前网络环境（也是其中一个因素！）】
- 【谷歌，twitter，youtube等可能无法ping通，正常现象！】
> **注意**：当你在使用此项目时，遇到任何无法独自解决的问题请优先前往 [Issues](https://github.com/Elegycloud/clash-for-linux-backup/issue) 寻找解决方法。由于空闲时间有限，后续将不再对Issues中 “已经解答”、“已有解决方案” 的问题进行重复性的回答。

<br>

# 使用教程

## 下载项目

下载项目

```bash
$ git clone https://github.com/azreallem/clash-for-linux-backup.git
```

进入到项目目录，编辑`.env`文件，修改变量`CLASH_URL`的值。

```bash
$ cd clash-for-linux-backup
$ vim .env
```

> **注意：** 在订阅链接末尾添加 &unset 再更新订阅。
>
> **注意：** `.env` 文件中的变量 `CLASH_SECRET` 为自定义 Clash Secret，值为空时，脚本将自动生成随机字符串。

<br>

## 启动程序

### 方式一：在线获取订阅并启动

直接运行脚本文件`sudo bash start.sh`

```bash
$ sudo bash start.sh
```

### 方式二：使用本地备份配置启动

如果您之前已成功启动过，且本地存在 `temp.bak/` 目录，可以使用此方式跳过下载直接启动。

```bash
$ sudo bash start_back.sh
```

<br>

## 加载环境变量

- 加载环境变量并开启代理

```bash
$ source /etc/profile.d/clash.sh
$ proxy_on
```

- 检查服务端口

```bash
$ netstat -tln | grep -E '9090|789.'
```

- 检查环境变量

```bash
$ env | grep -E 'http_proxy|https_proxy'
```

<br>

## 重启程序

如果需要对Clash配置进行修改，请修改 `conf/config.yaml` 文件。然后运行 `restart.sh` 脚本进行重启。

```bash
$ sudo bash restart.sh
```

> **注意：** 重启脚本 `restart.sh` 不会更新订阅信息。

<br>

## 停止程序

- 关闭服务

```bash
$ sudo bash shutdown.sh
$ proxy_off
```

<br>

## Clash Dashboard

- 访问 Clash Dashboard

通过浏览器访问 `start.sh` 执行成功后输出的地址，例如：http://192.168.0.1:9090/ui

- 登录管理界面

在`API Base URL`一栏中输入：http://\<ip\>:9090 ，在`Secret(optional)`一栏中输入启动成功后输出的Secret。

<br>

## 终端界面选择代理节点

脚本存放位置：`scripts/clash_proxy-selector.sh`

> **注意：** 使用脚本前，请确保 Secret 变量值与启动时一致。

<br>

# 常见问题

1. 部分Linux系统默认的 shell `/bin/sh` 被更改为 `dash`，建议使用 `bash xxx.sh` 运行脚本。
2. 部分用户在UI界面找不到代理节点，目前此项目已集成自动识别和转换clash配置文件的功能。
3. 程序日志中出现`error: unsupported rule type RULE-SET`报错，请在订阅链接末尾添加 `&unset`。