#!/bin/bash

# 替换环境变量到前端模板
# for at-auth
# export AUTH_MAX_USERS=1

# for at-server
# 从 BASE_URL 中提取 path 部分，再加上 /api 后缀
base_url_path=$(echo "$BASE_URL" | sed -E 's|^https?://[^/]*||')
export AT_HTTP_ROOT_PATH="${base_url_path}/api"  # 合并到一个 Nginx Port，URL增加前缀
export LANGFUSE_ENV_TAG=all-in-one
# for at-web
export AT_API_BASE_URL_EXTERNAL=${BASE_URL}/api


# for all-in-one init sample data
# export INIT_SAMPLE_DATA=1
# export AUTH_API_BASE_URL='http://127.0.0.1:8689/auth'


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
