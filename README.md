**察言观数（AskTable）是领先的企业级 AI 数据智能体（AI Data Agent） 平台**，为企业提供基于自然语言的数据分析体验，广泛支持 Excel、数据库和数据仓库的智能查询，应用于运营、财务、人事、销售等业务场景，解决企业管理和决策领域的关键问题，为企业打造新一代数据洞察与决策体系。

**AskTable 的目标：让每个人都能轻松、愉快地从数据中获取洞察。**

- [AskTable 官网](https://asktable.com/)
- [如何单机安装 AskTable](https://docs.asktable.com/docs/pricing-and-deployment/private-deployment-all-in-one)


&nbsp;

## 两大产品功能
### AI 问答查数
**企业软件的 AI 问数插件**
AskTable 能够集成到企业软件(如企业微信、飞书、钉钉、ERP、CRM等)内部，实现用自然语言查询企业核心数据库，并返回精准的结果。

**AI 知识库/智能体的结构化伙伴**
AskTable 能够集成到各类 AI知识库及智能体(如通过Dify、百炼、coze 等搭建)。智能体除了能够查询文本等非结构化数据外，还提供精准智能的查数问数。

### AI 分析报告
**主动报表分析**
通过一句话快速生成分析报表，结果包含总值、趋势、占比等数据，可自行设置分析维度。原本3天完成的分析报告只需2分钟，大幅提高企业数据分析效率。

**关联性分析**
AskTable 通过 AI以及业务知识深度理解各表格和字段的关联，对数据的成因、变化快速做出关联性分析，完善企业决策依据，提升决策效率。

**趋势预测分析**
精准预判，决策不“迷路”。察言观数能够通过已有的数据和结果，通过理解用户的自然语言，识别意图，并给出趋势预测和最有利的决策建议。
<img width="500" height="281" alt="image" src="https://github.com/user-attachments/assets/0dfb4b21-81b9-4045-8341-c3132867c3af" />


&nbsp;

## 在阿里云部署步骤

### **第一步：访问部署入口**

访问阿里云市场的 **AskTable 私有部署**。

<img width="525" height="316" alt="image" src="https://github.com/user-attachments/assets/019a7166-a175-468e-9007-46536eed4894" />


该页面提供官方镜像，确保部署过程稳定高效。

&nbsp;
### **第二步：选择实例规格并初始化配置**

根据数据处理需求选择合适的 **ECS 实例规格**，**建议最低配置为：**

- 2 核 CPU  
- 4 GB 内存

  <img width="479" height="416" alt="image" src="https://github.com/user-attachments/assets/3f960520-1517-42c7-9679-d2eb5015c4cb" />


在部署界面填写如下初始化信息：

- `AskTable LLM_API_KEY`
- 管理员用户名
- 管理员登录密码
这一步将自动完成系统初始化与权限配置。

&nbsp;
### **第三步：确认并启动部署**

点击 **“确认订单”** 并 **“立即部署”**。  
系统将在约 **2 分钟内** 完成自动部署流程。
<img width="540" height="468" alt="image" src="https://github.com/user-attachments/assets/ef027e6f-3368-4f82-8e1a-a021dae072b5" />

部署完成后，页面将生成登录地址，例如：http://123.123.123.123:8000/ 

使用您设置的管理员账号登录，即可访问系统，开始使用 **AskTable**。
<img width="540" height="275" alt="image" src="https://github.com/user-attachments/assets/0ae4cf9a-5831-4f13-a5b0-89abd524f5e5" />


&nbsp;
## 在 Sealos 部署步骤

### **1. 配置 AskTable**

`LLM_API_KEY` AI 模型令牌，是以"asktable-"开头的字符串。登录 [AskTable](https://cloud.asktable.com/?dialog=deployment) 获取。其他配置项可使用默认值。

<div style="text-align: center;">
  <img src="https://github.com/user-attachments/assets/3233df9d-d03b-4f9d-b1b5-3649b0aed4ad" alt="Image" width="500">
</div>

&nbsp;
### **2. 点击"部署应用"**

你可以在"应用管理"中查看部署状态。
<img width="565" height="183" alt="image" src="https://github.com/user-attachments/assets/87d1ad04-6f0b-4856-a144-fee68aa4665d" />

&nbsp;
### **3. 打开"公网地址"，即可访问 AskTable**

<img width="445" height="291" alt="image" src="https://github.com/user-attachments/assets/074507ab-5060-47ec-bb60-96dad6c1c018" />


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

公众号搜：AskTable

官网：https://asktable.com/

邮箱：hi@datamini.ai
