#!/bin/bash

echo "正在启动长坤机械订单管理系统..."
echo

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "错误：未检测到Node.js，请先安装Node.js 14.0或更高版本"
    echo "下载地址：https://nodejs.org/"
    exit 1
fi

# 检查MySQL客户端是否安装
if ! command -v mysql &> /dev/null; then
    echo "警告：未检测到MySQL命令行工具"
    echo "请确保MySQL服务正在运行，并且数据库配置正确"
    echo
fi

# 安装依赖
echo "正在检查依赖包..."
if [ ! -d "node_modules" ]; then
    echo "正在安装依赖包..."
    npm install
    if [ $? -ne 0 ]; then
        echo "错误：依赖包安装失败"
        exit 1
    fi
fi

# 启动服务器
echo
echo "正在启动服务器..."
echo "服务器地址：http://192.168.10.22:3001"
echo
echo "默认管理员账号："
echo "用户名：谢军强"
echo "密码：Xie750021"
echo
echo "按Ctrl+C停止服务器"
echo

node server.js