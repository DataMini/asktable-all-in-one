#!/bin/bash

# 初始化示例数据（用于在 ALLINONE 的 AskTable 中初始化示例MySQL、Project、Datasource、Bot等 Configuration）
# 1. Sample Data 跟 AskTable-Server 共用同一个 MySQL 实例，不同的 DB。
# 2. AskTable 配置的MySQL账号密码可以同时访问 AskTable DB 和 Sample Data DB 这两个数据库。
# 3. AskTable 需要配置一个 MYSQL_ROOT_PASSWORD 环境变量，用于初始化 Sample Data DB，并赋权。
# 4. 通过环境变量 INIT_SAMPLE_DATA 控制是否初始化示例数据。


# 实现细节
# 1. 创建数据库，并导入示例数据
# 2. 通过 AT_AUTH API /automation/import_project_for_admin 导入示例项目数据，并设置示例项目所有者为 ADMIN

# 切换到脚本所在目录
cd "$(dirname "$0")"

# 定义日志函数
log() {
  echo "INIT_SAMPLE_DATA: $1"
}

# 检查是否需要初始化示例数据
if [ -z "$INIT_SAMPLE_DATA" ] || [ "$INIT_SAMPLE_DATA" != "1" ]; then
  log "跳过示例数据初始化 (INIT_SAMPLE_DATA=${INIT_SAMPLE_DATA})"
  exit 0
fi

# 检查必要的环境变量
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  log "Error: MYSQL_ROOT_PASSWORD environment variable is not set"
  exit 1
fi

if [ -z "$AUTH_API_BASE_URL" ]; then
  log "Error: AUTH_API_BASE_URL environment variable is not set"
  exit 1
fi

# 设置默认值
SAMPLE_DB_NAME="asktable_sample_db"
MYSQL_PORT="${MYSQL_PORT:-3306}"


log "Database configuration:"
log "MYSQL_HOST: ${MYSQL_HOST}"
log "MYSQL_USER: ${MYSQL_USER}"
log "MYSQL_PASSWORD: ${MYSQL_PASSWORD}"
log "MYSQL_PORT: ${MYSQL_PORT}"
log "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}"
log "SAMPLE_DB_NAME: ${SAMPLE_DB_NAME}"

log "Start initializing sample data..."

# 等待服务启动的函数
wait_for_service() {
  local service=$1
  local max_attempts=10
  local attempt=1
  local wait_time=10

  log "Waiting for $service to be ready..."
  while [ $attempt -le $max_attempts ]; do
    if [ "$service" = "mysql" ]; then
      if mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
        log "$service is ready"
        return 0
      fi
    elif [ "$service" = "asktable" ]; then
      if curl -s "${AUTH_API_BASE_URL}" >/dev/null 2>&1; then
        log "$service is ready"
        return 0
      fi
    fi

    log "Attempt $attempt/$max_attempts: $service is not ready yet, waiting ${wait_time}s..."
    sleep $wait_time
    attempt=$((attempt + 1))
  done

  log "Error: $service failed to start after $max_attempts attempts"
  return 1
}

# 等待 MySQL 和 AskTable 服务就绪
wait_for_service "mysql" || exit 1
wait_for_service "asktable" || exit 1

# 检查数据库是否已存在
if mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "USE ${SAMPLE_DB_NAME}" >/dev/null 2>&1; then
  log "Database ${SAMPLE_DB_NAME} already exists, skipping database initialization"
else
  log "Creating and initializing database ${SAMPLE_DB_NAME}..."
  mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${SAMPLE_DB_NAME};"
  log "Database ${SAMPLE_DB_NAME} created successfully"
  mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" "${SAMPLE_DB_NAME}" < db.sql
  log "Tables in ${SAMPLE_DB_NAME} initialized successfully"
  
  # 为新创建的数据库授予 SELECT 权限
  log "Granting SELECT privileges to user ${MYSQL_USER}..."
  mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT SELECT ON ${SAMPLE_DB_NAME}.* TO '${MYSQL_USER}'@'%'; FLUSH PRIVILEGES;"
fi

# 创建临时项目配置文件
log "Creating temporary project configuration..."
export SAMPLE_DB_NAME MYSQL_HOST MYSQL_PORT MYSQL_USER MYSQL_PASSWORD
envsubst < project.json > project-new.json

# 导入项目数据
log "Importing project data..."
HTTP_CODE=$(curl -s -w "%{http_code}" -X POST "${AUTH_API_BASE_URL}/automation/import_project_for_admin" \
  -H "Authorization: Bearer ${AUTH_SYS_ADMIN_KEY}" \
  -F "file=@project-new.json" -o /dev/null)

if [ "$HTTP_CODE" = "200" ]; then
  log "Project data imported successfully"
else
  log "Failed to import project data (HTTP code: ${HTTP_CODE})"
fi

