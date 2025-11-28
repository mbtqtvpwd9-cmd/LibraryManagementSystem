# 腾讯云Ubuntu服务器部署指南

## 环境要求
- Ubuntu 22.04
- Docker 26+
- Maven 3.6+
- OpenJDK 17+

## 快速部署

### 方法1: 使用快速部署脚本
```bash
./quick-deploy-tencent.sh
```

### 方法2: 使用完整部署脚本
```bash
./deploy-tencent-cloud.sh
```

### 方法3: 手动部署
```bash
# 1. 构建项目
mvn clean package -DskipTests

# 2. 启动服务
docker-compose -f docker-compose.tencent.yml up -d

# 3. 查看状态
docker-compose -f docker-compose.tencent.yml ps
```

## 服务配置

### 应用服务
- **端口**: 8080
- **镜像**: openjdk:17-jdk-slim
- **配置文件**: docker-compose.tencent.yml

### 数据库服务
- **端口**: 3306
- **镜像**: mysql:8.0
- **数据库**: library_db
- **用户名**: root / library_user
- **密码**: rootpassword / library_password

## 访问信息

### 应用访问
- **本地访问**: http://localhost:8080
- **外网访问**: http://服务器IP:8080

### 默认账户
- **管理员**: admin / admin123
- **读者**: reader / reader123

## 常用命令

```bash
# 查看服务状态
docker-compose -f docker-compose.tencent.yml ps

# 查看应用日志
docker-compose -f docker-compose.tencent.yml logs -f app

# 查看数据库日志
docker-compose -f docker-compose.tencent.yml logs -f db

# 停止服务
docker-compose -f docker-compose.tencent.yml down

# 重启服务
docker-compose -f docker-compose.tencent.yml restart

# 完全清理（包括数据）
docker-compose -f docker-compose.tencent.yml down -v
```

## 故障排除

### 1. 端口冲突
```bash
# 检查端口占用
sudo netstat -tlnp | grep :8080
sudo netstat -tlnp | grep :3306

# 修改端口配置
# 编辑 docker-compose.tencent.yml
```

### 2. 内存不足
```bash
# 检查内存使用
free -h

# 清理Docker
docker system prune -a
```

### 3. 网络问题
```bash
# 检查防火墙
sudo ufw status

# 开放端口
sudo ufw allow 8080
sudo ufw allow 3306
```

### 4. 数据库连接失败
```bash
# 检查数据库状态
docker-compose -f docker-compose.tencent.yml logs db

# 重启数据库
docker-compose -f docker-compose.tencent.yml restart db
```

## 监控和维护

### 健康检查
```bash
# 检查应用健康状态
curl http://localhost:8080/api/users/login

# 检查数据库连接
docker exec library-db mysql -uroot -prootpassword -e "SHOW DATABASES;"
```

### 备份数据
```bash
# 备份数据库
docker exec library-db mysqldump -uroot -prootpassword library_db > backup.sql

# 恢复数据库
docker exec -i library-db mysql -uroot -prootpassword library_db < backup.sql
```

## 性能优化

### JVM参数调优
在 `docker-compose.tencent.yml` 中添加：
```yaml
environment:
  - JAVA_OPTS=-Xmx1g -Xms512m -XX:+UseG1GC
command: ["sh", "-c", "java $$JAVA_OPTS -jar /app/app.jar"]
```

### 数据库优化
在 `docker-compose.tencent.yml` 中添加：
```yaml
command: >
  --default-authentication-plugin=mysql_native_password
  --innodb-buffer-pool-size=256M
  --max-connections=200
```

## 安全建议

1. **修改默认密码**: 首次部署后修改数据库和应用的默认密码
2. **配置防火墙**: 只开放必要的端口
3. **使用HTTPS**: 配置SSL证书启用HTTPS
4. **定期备份**: 设置自动备份策略
5. **监控日志**: 定期检查应用和数据库日志