#!/bin/bash

# 初始化示例数据（用于在 ALLINONE 的 AskTable 中初始化示例MySQL、Project、Datasource、Bot等 Configuration）
# 1. Sample Data 跟 AskTable-Server 共用同一个 MySQL 实例，不同的 DB。
# 2. AskTable 配置的MySQL账号密码可以同时访问 AskTable DB 和 Sample Data DB 这两个数据库。
# 3. AskTable 需要配置一个 MYSQL_ROOT_PASSWORD 环境变量，用于初始化 Sample Data DB，并赋权。
# 4. 通过环境变量 INIT_SAMPLE_DATA 控制是否初始化示例数据。


# 切换到脚本所在目录
cd "$(dirname "$0")"

# 检查是否需要初始化示例数据
if [ "$INIT_SAMPLE_DATA" != "1" ]; then
  echo "Skip sample data initialization"
  exit 0
fi

# 检查必要的环境变量
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "Error: MYSQL_ROOT_PASSWORD environment variable is not set"
  exit 1
fi


# 设置默认值
SAMPLE_DB_NAME="asktable_sample_db"

echo "Database configuration:"
echo "MYSQL_HOST: ${MYSQL_HOST}"
echo "MYSQL_USER: ${MYSQL_USER}"
echo "MYSQL_PASSWORD: ${MYSQL_PASSWORD}"
echo "MYSQL_PORT: ${MYSQL_PORT}"
echo "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}"
echo "SAMPLE_DB_NAME: ${SAMPLE_DB_NAME}"

echo "Start initializing sample data..."

# 等待服务启动的函数
wait_for_service() {
  local service=$1
  local max_attempts=5
  local attempt=1
  local wait_time=10

  echo "Waiting for $service to be ready..."
  while [ $attempt -le $max_attempts ]; do
    if [ "$service" = "mysql" ]; then
      if mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
        echo "$service is ready"
        return 0
      fi
    elif [ "$service" = "asktable" ]; then
      if curl -s "${AT_API_BASE_URL}" >/dev/null 2>&1; then
        echo "$service is ready"
        return 0
      fi
    fi

    echo "Attempt $attempt/$max_attempts: $service is not ready yet, waiting ${wait_time}s..."
    sleep $wait_time
    attempt=$((attempt + 1))
  done

  echo "Error: $service failed to start after $max_attempts attempts"
  return 1
}

# 等待 MySQL 和 AskTable 服务就绪
wait_for_service "mysql" || exit 1
wait_for_service "asktable" || exit 1

# 检查数据库是否已存在
if mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "USE ${SAMPLE_DB_NAME}" >/dev/null 2>&1; then
  echo "Database ${SAMPLE_DB_NAME} already exists, skipping database initialization"
else
  echo "Creating and initializing database ${SAMPLE_DB_NAME}..."
  mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${SAMPLE_DB_NAME};"
  mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" "${SAMPLE_DB_NAME}" < db.sql
  
  # 为新创建的数据库授予 SELECT 权限
  echo "Granting SELECT privileges to user ${MYSQL_USER}..."
  mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT SELECT ON ${SAMPLE_DB_NAME}.* TO '${MYSQL_USER}'@'%'; FLUSH PRIVILEGES;"
fi

# 创建临时项目配置文件
echo "Creating temporary project configuration..."
export SAMPLE_DB_NAME MYSQL_HOST MYSQL_PORT MYSQL_USER MYSQL_PASSWORD
envsubst < project.json > project.json.tmp

# 导入项目数据
echo "Importing project data..."
curl -X POST "${AT_API_BASE_URL}/sys/projects/import" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${AT_SYS_API_KEY}" \
  -d @project.json.tmp

# 清理临时文件
rm project.json.tmp

echo "Sample data initialization completed" 