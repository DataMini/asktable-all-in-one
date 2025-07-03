#!/bin/bash

# 替换环境变量到前端模板
# for at-web
export AT_API_BASE_URL_EXTERNAL=${BASE_URL}/api
export AUTH_API_BASE_URL_EXTERNAL=${BASE_URL}/auth
export AT_WEB_DEPLOYMENT_MODEL=local

# for at-auth
export AT_API_BASE_URL='http://127.0.0.1:8688/api/v1'
export AT_SYS_API_KEY=asktable
export AUTH_SYS_ADMIN_KEY=asktable
export AUTH_MAX_USERS=1
export AT_AUTH_DEPLOYMENT_MODEL=local
export AUTH_HTTP_ROOT_PATH='/auth'  # 合并到一个 Nginx Port，URL增加前缀

# for at-server
export AT_HTTP_ROOT_PATH='/api'  # 合并到一个 Nginx Port，URL增加前缀
export LANGFUSE_ENV_TAG=all-in-one
export AT_HTTP_HOST_EXTERNAL=${BASE_URL}/api


# for all-in-one init sample data
export INIT_SAMPLE_DATA=1
export AUTH_API_BASE_URL='http://127.0.0.1:8689/auth'

# for mcp sse server
export MCP_SSE_SERVER_PORT=8690

# 设置AT-Web参数
envsubst < /usr/share/nginx/html/env-config.js.template > /usr/share/nginx/html/env-config.js

# 如果设置了 AT_WEB_TITLE，则修改index.html文件中的标题
if [ ! -z "$AT_WEB_TITLE" ]; then
  sed -i "s|<title>.*</title>|<title>$AT_WEB_TITLE</title>|g" /usr/share/nginx/html/index.html  
fi

# 如果设置了 AT_WEB_DESCRIPTION，则修改index.html文件中的描述
if [ ! -z "$AT_WEB_DESCRIPTION" ]; then
  sed -i "s|<meta[[:space:]]*name=\"description\"[[:space:]]*content=\".*\"/>|<meta name=\"description\" content=\"$AT_WEB_DESCRIPTION\"/>|g" /usr/share/nginx/html/index.html
fi

# 启动 Supervisor
exec supervisord -c /etc/supervisor/supervisord.conf
