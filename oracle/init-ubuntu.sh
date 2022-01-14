#!/bin/bash

# 颜色
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}

cur_dir=$(pwd)
scripts_dir='/home/ubuntu/init_scripts'

# check arch
arch=$(arch)

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
  arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
  arch="arm64"
else
  arch="amd64"
  red "检测架构失败，使用默认架构: ${arch}${plain}"
fi

green "架构: ${arch}"

# demo:　down_sh url shell.sh
down_sh(){
  curl -fsSL $1 -o $2
}

run_sh(){
  chmod +x $1
  chmod 777 $1
  yellow "下载完成, 之后可执行 sudo bash $1 再次运行"
  bash $1
}

fix_iptables() {
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    apt purge netfilter-persistent
}

install_docker() {
  s="$scripts_dir/get-docker.sh"
  down_sh https://get.docker.com $s
  run_sh $s
}

install_base() {
  green "apt update..."
  apt update
  apt install wget curl git jq net-tools -y
}

install_x_ui() {
  s="$scripts_dir/x-ui.sh"
  down_sh https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh $s
  run_sh $s
}

#获取本机IP
function get_ip(){
  echo
  curl ip.p3terx.com
  echo
}

#IPV.SH ipv4/6优先级调整
function ipvsh(){
  s="$scripts_dir/ipv4.sh"
  down_sh https://raw.githubusercontent.com/Netflixxp/jcnf-box/master/sh/ipv4.sh $s
  run_sh $s
}

init(){
  install_base
  fix_iptables
  install_docker
}

run(){
  green " 1. init 初始化"
  green " 2. install_docker"
  green " 3. install_x_ui"
  green " 4. get_ip"
  green " 5. ipvsh ipv4, ipv6优先级切换"
  # read -p "请输入数字:" menuNumberInput
  green "run $1"
  case "$1" in
    init )
      init
    ;;

    install_docker )
      install_docker
    ;;

    install_x_ui )
      install_x_ui
    ;;

    get_ip )
      get_ip
    ;;

    ipvsh )
      ipvsh
    ;;

    * )
        red "请输入命令: bash ~/init.sh <script_name>"
        exit 1
    ;;
  esac
}

run $1 $2 $3 $4
