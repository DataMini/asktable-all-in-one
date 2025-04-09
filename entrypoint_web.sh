#!/bin/sh

# 设置默认值
DEFAULT_TITLE="有数据库就用 AskTable"
DEFAULT_DESCRIPTION="让每个人都能轻松、愉快地从数据中获得洞察。AskTable 是一款利用人工智能技术，帮助企业通过自然语言查询和分析电子表格、数据库以及大数据的工具。"

# 如果环境变量未设置，则使用默认值
if [ -z "$AT_WEB_TITLE" ]; then
  export AT_WEB_TITLE="$DEFAULT_TITLE"
fi

if [ -z "$AT_WEB_DESCRIPTION" ]; then
  export AT_WEB_DESCRIPTION="$DEFAULT_DESCRIPTION"
fi

# 检查是否配置了AT_WEB_BRANDING_NAME环境变量
if [ ! -z "$AT_WEB_BRANDING_NAME" ]; then
  envsubst < /usr/share/nginx/html/env-config.js.template1 > /usr/share/nginx/html/env-config.js
else
  envsubst < /usr/share/nginx/html/env-config.js.template > /usr/share/nginx/html/env-config.js
fi

# 直接修改index.html文件中的环境变量
sed -i "s|<title>.*</title>|<title>$AT_WEB_TITLE</title>|g" /usr/share/nginx/html/index.html
sed -i "s|<meta[[:space:]]*name=\"description\"[[:space:]]*content=\".*\"/>|<meta name=\"description\" content=\"$AT_WEB_DESCRIPTION\"/>|g" /usr/share/nginx/html/index.html

# Start Nginx
nginx -g 'daemon off;'
