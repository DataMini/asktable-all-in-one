#!/bin/bash

# 替换环境变量到前端模板
# for at-web
export AT_API_BASE_URL_EXTERNAL=${BASE_URL}/api
export AUTH_API_BASE_URL_EXTERNAL=${BASE_URL}/auth
export AT_WEB_DEPLOYMENT_MODEL=local

# for at-auth
export AT_API_BASE_URL='http://127.0.0.1:8688/api/v1'
export AT_SYS_API_KEY=asktable
export AUTH_MAX_USERS=1

# 合并到一个 Nginx Port，URL增加前缀
export AUTH_HTTP_ROOT_PATH='/auth'
export AT_AUTH_DEPLOYMENT_MODEL=local

# for at-server
# 合并到一个 Nginx Port，URL增加前缀
export AT_HTTP_ROOT_PATH='/api'
export LANGFUSE_ENV_TAG=all-in-one
export AT_HTTP_HOST_EXTERNAL=${BASE_URL}/api

envsubst < /usr/share/nginx/html/env-config.js.template > /usr/share/nginx/html/env-config.js

# 启动 Supervisor
exec supervisord -c /etc/supervisor/supervisord.conf
