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
scripts_dir='~/init_scripts'

# check root
# [[ $EUID -ne 0 ]] && red "错误：${plain} 必须使用root用户运行此脚本！\n" && exit 1

# check os
# [[ x"${release}" != x"ubuntu" ]] && red "请使用 Ubuntu 16 或更高版本的系统！${plain}\n" && exit 1

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

green "mkdir ${scripts_dir}"
mkdir $scripts_dir

fix_iptables() {
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    apt purge netfilter-persistent
}

install_docker() {
  curl -fsSL https://get.docker.com -o $scripts_dir/get-docker.sh
  bash $scripts_dir/get-docker.sh
}

install_base() {
  green "apt update..."
  apt update
  apt install wget curl git -y
}

install_x_ui() {
  bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}

#获取本机IP
function get_ip(){
  echo
  curl ip.p3terx.com
  echo
}

#IPV.SH ipv4/6优先级调整
function ipvsh(){
  wget -O "$scripts_dir/ipv4.sh" "https://raw.githubusercontent.com/Netflixxp/jcnf-box/master/sh/ipv4.sh" --no-check-certificate -T 30 -t 5 -d
  chmod +x "$scripts_dir/ipv4.sh"
  chmod 777 "$scripts_dir/ipv4.sh"
  yellow "下载完成, 之后可执行 sudo bash $scripts_dir/ipv4.sh 再次运行"
  bash "$scripts_dir/ipv4.sh"
}

init(){
  fix_iptables
  install_docker
}

run(){
  clear
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
        clear
        red "请输入命令: bash ~/init_scripts/init.sh <script_name>"
        exit 1
    ;;
  esac
}

install_base
run $1
