#!/bin/bash

# 在Ubuntu上安装Docker和Docker Compose
# 适用于Ubuntu 22.04

echo "=== 安装Docker和Docker Compose ==="

# 1. 更新包索引
echo "1. 更新包索引..."
sudo apt-get update

# 2. 安装必要的包
echo "2. 安装必要的依赖..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 3. 添加Docker官方GPG密钥
echo "3. 添加Docker GPG密钥..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 4. 设置Docker仓库
echo "4. 设置Docker仓库..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. 安装Docker Engine
echo "5. 安装Docker Engine..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# 6. 启动Docker服务
echo "6. 启动Docker服务..."
sudo systemctl start docker
sudo systemctl enable docker

# 7. 将当前用户添加到docker组
echo "7. 添加用户到docker组..."
sudo usermod -aG docker $USER

# 8. 安装Docker Compose
echo "8. 安装Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 9. 验证安装
echo "9. 验证安装..."
sudo docker --version
sudo docker-compose --version

echo ""
echo "✅ Docker安装完成！"
echo ""
echo "注意事项："
echo "1. 请重新登录以使用户组生效"
echo "2. 或者运行: newgrp docker"
echo "3. 然后可以运行: docker run hello-world"
echo ""
echo "安装完成后，可以运行："
echo "./deploy-tencent-cloud.sh"