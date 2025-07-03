# AskTable All-in-One

AskTable AI 致力于让每个人都能轻松、平等地从数据中获取洞察。

- [AskTable 官网](https://asktable.com/)

- [如何单机安装 AskTable](https://docs.asktable.com/docs/pricing-and-deployment/private-deployment-all-in-one)

## 服务组件

本 All-in-One 容器包含以下服务组件：

- **AskTable Server**: 核心服务
- **AskTable Auth**: 用户认证和权限管理服务  
- **AskTable Web**: 前端 Web 界面
- **MCP SSE Server**: Model Context Protocol Server-Sent Events 服务
- **Nginx**: 反向代理和负载均衡
- **MySQL**: 数据存储（可选，支持外部数据库）

## 构建选项

### 使用国内镜像源

在中国网络环境下，可以通过构建参数启用国内镜像源来加速 Python 包的下载：

```bash
# 使用国内镜像源构建
docker build --build-arg USE_MIRROR=1 -t asktable-all-in-one .

# 不使用镜像源构建（默认）
docker build -t asktable-all-in-one .
```

**构建参数说明：**
- `USE_MIRROR=1`: 启用清华大学 PyPI 镜像源
- `USE_MIRROR=0` 或不设置: 使用官方 PyPI 源（默认）

**支持的镜像源：**
- 清华大学镜像源：`https://pypi.tuna.tsinghua.edu.cn/simple`

## 在 Sealos 部署步骤

**1. 配置 AskTable**

`LLM_API_KEY` AI 模型令牌，是以"asktable-"开头的字符串。登录 [AskTable](https://cloud.asktable.com/?dialog=deployment) 获取。其他配置项可使用默认值。

<div style="text-align: center;">
  <img src="https://github.com/user-attachments/assets/3233df9d-d03b-4f9d-b1b5-3649b0aed4ad" alt="Image" width="500">
</div>

**2. 点击"部署应用"**

你可以在"应用管理"中查看部署状态。

![image](https://github.com/user-attachments/assets/aabe6fd6-4829-4acb-ba0b-316af9dd0826)


![image](https://github.com/user-attachments/assets/44a50063-71a0-4981-a37e-863349cdefe2)


**3. 打开"公网地址"，即可访问 AskTable**

![image](https://github.com/user-attachments/assets/4d696986-9be9-48b3-b3e0-c333aa9d8b30)

## 部署后访问信息

### 主要访问地址

- **Web 界面**: `http://your-domain/` - AskTable 的主要用户界面
- **API 服务**: `http://your-domain/api/` - 后端 API 接口
- **认证服务**: `http://your-domain/auth/` - 用户认证和权限管理
- **MCP SSE 服务**: `http://your-domain/mcp/` - Model Context Protocol Server-Sent Events 服务

### 服务端口映射

容器内部服务端口映射：
- **AskTable Server**: 8688
- **AskTable Auth**: 8689  
- **MCP SSE Server**: 8690
- **Nginx**: 80 (对外端口)

### 环境变量配置

可通过以下环境变量自定义配置：

```bash
# 基础配置
BASE_URL=http://your-domain
AT_WEB_TITLE=AskTable
AT_WEB_DESCRIPTION=AI-powered data analysis platform

# AI 模型配置
LLM_API_KEY=asktable-your-api-key

# 数据库配置（可选）
MYSQL_HOST=your-mysql-host
MYSQL_PORT=3306
MYSQL_USER=your-mysql-user
MYSQL_PASSWORD=your-mysql-password
MYSQL_DATABASE=asktable
```

### 日志查看

所有服务日志通过 supervisord 统一管理，可通过以下命令查看：

```bash
# 查看所有服务状态
docker exec -it your-container-name supervisorctl status

# 查看特定服务日志
docker exec -it your-container-name supervisorctl tail -f asktable-server
docker exec -it your-container-name supervisorctl tail -f mcp-sse-server
```

### 服务管理

使用 supervisord 管理服务：

```bash
# 重启特定服务
docker exec -it your-container-name supervisorctl restart asktable-server
docker exec -it your-container-name supervisorctl restart mcp-sse-server

# 停止/启动服务
docker exec -it your-container-name supervisorctl stop/start service-name
```

## 联系我们

公众号搜：AskTable

官网：https://asktable.com/

邮箱：hi@datamini.ai
