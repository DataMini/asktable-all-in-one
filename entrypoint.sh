#!/bin/bash

base_path="${BASE_PATH:-}"

# for at-server
export AT_HTTP_ROOT_PATH="${base_path}/api"
export LANGFUSE_ENV_TAG=all-in-one

# for at-web
# 替换 index.html 中的 <base> 占位符
sed -i "s|__BASE_PATH__|${base_path}|g" /usr/share/nginx/html/index.html

# 生成 config.js，api_url 由前端自动推导 origin + base_path + /api
cat > /usr/share/nginx/html/config.js << EOF
window.env = {
    base_path: "${base_path}",
    app_name: "${APP_NAME:-AskTable}"
};
EOF

# 可选：替换标题
if [ -n "$APP_TITLE" ]; then
    sed -i "s|<title>.*</title>|<title>$APP_TITLE</title>|g" /usr/share/nginx/html/index.html
fi

# 可选：替换描述
if [ -n "$APP_DESCRIPTION" ]; then
    sed -i "s|<meta[[:space:]]*name=\"description\"[[:space:]]*content=\".*\"/>|<meta name=\"description\" content=\"$APP_DESCRIPTION\"/>|g" /usr/share/nginx/html/index.html
fi

# 启动 Supervisor
exec supervisord -c /etc/supervisor/supervisord.conf
