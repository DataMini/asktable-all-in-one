**察言观数（AskTable）是领先的企业级 AI 数据智能体（AI Data Agent） 平台**，为企业提供基于自然语言的数据分析体验，广泛支持 Excel、数据库和数据仓库的智能查询，应用于运营、财务、人事、销售等业务场景，解决企业管理和决策领域的关键问题，为企业打造新一代数据洞察与决策体系。

**AskTable 的目标：让每个人都能轻松、愉快地从数据中获取洞察。**

- [AskTable 官网](https://asktable.com/)
- [如何单机安装 AskTable](https://docs.asktable.com/docs/pricing-and-deployment/private-deployment-all-in-one)
- [产品功能及优势](https://docs.asktable.com/docs/introduction/core-features)

<img width="750" height="421" alt="image" src="https://github.com/user-attachments/assets/0dfb4b21-81b9-4045-8341-c3132867c3af" />


&nbsp;

## 部署方式

1、在阿里云部署： [文档链接](https://docs.asktable.com/docs/pricing-and-deployment/private-deployment-on-aliyun)

2、在 Sealos 部署： [文档链接](https://docs.asktable.com/docs/pricing-and-deployment/deploy-on-sealos)


&nbsp;
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

&nbsp;

## 服务组件
本 All-in-One 容器包含以下服务组件：

- **AskTable Server**: 核心服务
- **AskTable Auth**: 用户认证和权限管理服务  
- **AskTable Web**: 前端 Web 界面
- **MCP SSE Server**: Model Context Protocol Server-Sent Events 服务
- **Nginx**: 反向代理和负载均衡
- **MySQL**: 数据存储（可选，支持外部数据库）

&nbsp;

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

&nbsp;

## 联系我们

公众号搜：察言观数AskTable

官网：https://asktable.com/

邮箱：hi@datamini.ai
