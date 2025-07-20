# VSS 本地开发环境安装指南

## 概述

VSS 项目提供了多种本地开发环境的安装和配置方案，适应不同的使用场景和网络环境。

## 安装脚本说明

### 1. `install-local-env.bat` - 完整自动安装
**适用场景：** 全新环境，需要自动安装所有开发工具
**特点：**
- 自动安装 Chocolatey 包管理器
- 自动下载并安装 Node.js、Java JDK、Maven、Git
- 自动下载并配置 Nginx
- 安装项目依赖
- 创建启动脚本

**使用方法：**
```bash
# 右键以管理员身份运行
install-local-env.bat
```

### 2. `setup-local-env.bat` - 快速配置
**适用场景：** 已安装基础开发工具，只需配置项目环境
**特点：**
- 检查现有工具安装状态
- 安装项目依赖
- 创建启动脚本
- 配置现有 Nginx

**使用方法：**
```bash
# 双击运行
setup-local-env.bat
```

### 3. `Install-LocalEnv.ps1` - PowerShell 高级版
**适用场景：** 需要更强大功能和错误处理的环境
**特点：**
- 支持参数化安装
- 更好的错误处理
- 支持 winget 和 chocolatey
- 可跳过下载仅配置

**使用方法：**
```powershell
# 基本安装
.\Install-LocalEnv.ps1

# 快速设置（仅配置）
.\Install-LocalEnv.ps1 -QuickSetup

# 跳过下载
.\Install-LocalEnv.ps1 -SkipDownloads

# 自定义安装路径
.\Install-LocalEnv.ps1 -InstallPath "C:\MyDevTools"
```

## 系统要求

### 最低要求
- Windows 10/11
- 4GB RAM
- 10GB 可用磁盘空间
- 稳定的网络连接（用于下载依赖）

### 推荐配置
- Windows 11
- 8GB+ RAM
- 20GB+ 可用磁盘空间
- SSD 硬盘

## 预安装要求

### 必须手动安装的工具
如果选择快速配置模式，需要预先安装：

1. **Node.js LTS**
   - 下载：https://nodejs.org/
   - 推荐版本：18.x 或 20.x

2. **Java JDK 17+**
   - 下载：https://adoptium.net/
   - 推荐版本：OpenJDK 17

3. **Git**（可选，但推荐）
   - 下载：https://git-scm.com/download/win

### 可选工具
1. **Apache Maven**
   - 下载：https://maven.apache.org/download.cgi
   - 注意：项目包含内置的 mvnw，不强制要求

2. **Nginx**
   - 下载：http://nginx.org/en/download.html
   - 注意：脚本可自动安装，也可手动安装

## 端口配置

### 默认端口分配
- **前端开发服务器：** 3000
- **后端开发服务器：** 3002  
- **Nginx 代理服务器：** 8080

### 端口冲突解决
如果遇到端口冲突，可以：

1. **检查端口占用：**
```bash
netstat -ano | findstr ":3000"
netstat -ano | findstr ":3002" 
netstat -ano | findstr ":8080"
```

2. **修改端口配置：**
   - 前端：编辑 `VSS-frontend/vite.config.ts`
   - 后端：编辑 `VSS-backend/src/main/resources/application.properties`
   - Nginx：编辑 `nginx-local.conf`

## 使用流程

### 首次安装
1. 选择合适的安装脚本
2. 运行安装脚本
3. 等待安装完成
4. 运行 `start-all.bat` 启动所有服务
5. 访问 http://localhost:8080 查看应用

### 日常开发
1. 运行 `start-all.bat` 启动所有服务
2. 进行开发工作
3. 前端代码会自动热重载
4. 后端代码修改需要重启服务
5. 运行 `stop-all.bat` 停止所有服务

## 启动脚本说明

### 创建的脚本文件
- `start-all.bat` - 一键启动所有服务
- `start-frontend.bat` - 仅启动前端开发服务器
- `start-backend.bat` - 仅启动后端开发服务器
- `start-nginx.bat` - 仅启动 Nginx 代理（如果已安装）
- `stop-all.bat` - 停止所有服务
- `dev-guide.bat` - 查看开发指南

### 访问地址
- **推荐（通过 Nginx 代理）：** http://localhost:8080
- **前端直连：** http://localhost:3000
- **后端 API：** http://localhost:3002

## 故障排除

### 常见问题

#### 1. Node.js 安装失败
**解决方案：**
- 手动下载安装：https://nodejs.org/
- 确保选择 LTS 版本
- 安装时勾选"Add to PATH"

#### 2. Java 安装失败
**解决方案：**
- 手动下载安装：https://adoptium.net/
- 安装后设置 JAVA_HOME 环境变量
- 将 %JAVA_HOME%\bin 添加到 PATH

#### 3. 前端依赖安装失败
**解决方案：**
```bash
cd VSS-frontend
npm cache clean --force
npm install
```

#### 4. 后端启动失败
**解决方案：**
```bash
cd VSS-backend
.\mvnw.cmd clean install
.\mvnw.cmd spring-boot:run
```

#### 5. Nginx 启动失败
**解决方案：**
- 检查配置文件语法：`nginx -t`
- 检查端口是否被占用
- 查看错误日志：`nginx/logs/error.log`

#### 6. 端口被占用
**解决方案：**
```bash
# 查找占用进程
netstat -ano | findstr ":端口号"

# 强制结束进程
taskkill /f /pid 进程ID
```

### 日志位置
- **前端：** 控制台输出
- **后端：** VSS-backend/logs/
- **Nginx：** nginx/logs/

### 性能优化建议
1. 使用 SSD 硬盘
2. 为 Node.js 配置国内镜像：
```bash
npm config set registry https://registry.npmmirror.com
```
3. 为 Maven 配置国内镜像（编辑 settings.xml）

## 网络环境配置

### 企业网络/受限环境
如果在企业网络或受限环境中：

1. **使用离线安装包：**
   - 预先下载所有安装包
   - 使用 `-SkipDownloads` 参数

2. **配置代理：**
```bash
# npm 代理
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080

# git 代理
git config --global http.proxy http://proxy.company.com:8080
```

## 开发工作流

### 推荐的开发流程
1. 启动所有服务：`start-all.bat`
2. 在浏览器中打开：http://localhost:8080
3. 使用 VS Code 打开项目目录
4. 前端开发：编辑 `VSS-frontend/src/` 下的文件
5. 后端开发：编辑 `VSS-backend/src/` 下的文件
6. 提交代码前运行测试
7. 停止服务：`stop-all.bat`

### 热重载说明
- **前端：** Vite 提供自动热重载，代码修改立即生效
- **后端：** Spring Boot DevTools 支持热重载，但建议重启服务以确保稳定性

## 版本升级

### 更新依赖
```bash
# 更新前端依赖
cd VSS-frontend
npm update

# 更新后端依赖
cd VSS-backend
.\mvnw.cmd clean install
```

### 重新配置环境
如需重新配置，删除生成的启动脚本后重新运行安装脚本即可。

---

**注意：** 如果遇到任何问题，请查看相应的错误日志，或参考本文档的故障排除部分。
