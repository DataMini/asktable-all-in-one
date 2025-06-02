# 使用已有的三种镜像作为构建阶段源
FROM registry.cn-shanghai.aliyuncs.com/datamini/asktable-auth:latest AS auth
FROM registry.cn-shanghai.aliyuncs.com/datamini/asktable-web:latest AS web


# 使用 asktable-server 作为基础镜像
FROM registry.cn-shanghai.aliyuncs.com/datamini/asktable-server-bin:latest


# 安装 supervisord、nginx
RUN apt-get update && apt-get install -y supervisor nginx telnet gettext-base default-mysql-client curl

# 复制各服务文件到主镜像
COPY --from=auth /at_auth /at_auth
COPY --from=web /usr/share/nginx/html /usr/share/nginx/html
COPY --from=web /etc/nginx/nginx.conf /etc/nginx/nginx.conf

# 复制示例数据文件
COPY sample-data /at_sample_data

# auth 用 requirements.txt
RUN poetry config virtualenvs.create true && poetry install --directory /at_auth --no-interaction --no-ansi --no-root --without dev

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

