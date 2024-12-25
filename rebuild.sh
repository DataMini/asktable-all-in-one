#!/bin/bash

base_dir=$(pwd)

at_all_in_one_dir=${base_dir}
at_server_dir=${base_dir}/../rmb/
at_auth_dir=${base_dir}/../dm-user-sys/
at_web_dir=${base_dir}/../asktable-web/at-web/

echo "all-in-one: $at_all_in_one_dir"
echo "server: $at_server_dir"
echo "auth: $at_auth_dir"
echo "web: $at_web_dir"

# rebuild server
cd $at_server_dir && docker build -t registry.cn-shanghai.aliyuncs.com/datamini/asktable-server:latest .

# rebuild auth
cd $at_auth_dir && docker build -t registry.cn-shanghai.aliyuncs.com/datamini/asktable-auth:latest .

# rebuild web
cd $at_web_dir && docker build --build-arg USE_MIRROR=1 -t registry.cn-shanghai.aliyuncs.com/datamini/asktable-web:latest .


cd $at_all_in_one_dir && docker build -t registry.cn-shanghai.aliyuncs.com/datamini/asktable-all-in-one:latest . && docker-compose down && rm -rf mysql_data && docker-compose up -d
