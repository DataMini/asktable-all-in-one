# 使用已有的三种镜像作为构建阶段源
FROM registry.cn-shanghai.aliyuncs.com/datamini/asktable-auth:latest AS auth
FROM registry.cn-shanghai.aliyuncs.com/datamini/asktable-web:latest AS web

# 构建参数：是否使用国内镜像源
ARG USE_MIRROR=0

# 使用 asktable-server 作为基础镜像
FROM registry.cn-shanghai.aliyuncs.com/datamini/asktable-server-bin:latest

# 安装 supervisord、nginx
RUN apt-get update && apt-get install -y supervisor nginx telnet gettext-base default-mysql-client curl

# 安装 uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN . $HOME/.local/bin/env && uv tool install asktable-mcp-server@latest

# 复制各服务文件到主镜像
COPY --from=auth /at_auth /at_auth
COPY --from=web /usr/share/nginx/html /usr/share/nginx/html
COPY --from=web /etc/nginx/nginx.conf /etc/nginx/nginx.conf

# 复制示例数据文件
COPY sample-data /at_sample_data

# auth 用 requirements.txt
RUN if [ "$USE_MIRROR" = "1" ]; then \
        pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
        pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn && \
        poetry config repositories.pypi https://pypi.tuna.tsinghua.edu.cn/simple && \
        poetry config repositories.pypi-tuna https://pypi.tuna.tsinghua.edu.cn/simple && \
        poetry config virtualenvs.create true && \
        poetry install --directory /at_auth --no-interaction --no-ansi --no-root --without dev --source pypi-tuna; \
    else \
        poetry config virtualenvs.create true && \
        poetry install --directory /at_auth --no-interaction --no-ansi --no-root --without dev; \
    fi

# 复制代理配置
COPY asktable-proxy.conf /etc/nginx/conf.d/asktable-proxy.conf

# 配置 Supervisor 来管理多个服务
COPY supervisord.conf /etc/supervisor/supervisord.conf

# 设置初始化脚本权限
RUN chmod +x /at_sample_data/init.sh

# 配置启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# 暴露端口
EXPOSE 80

# 入口点
ENTRYPOINT ["/entrypoint.sh"]

