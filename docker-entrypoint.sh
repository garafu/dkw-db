#! /bin/sh
INIT_FLAG_FILE=/data/db/init-completed
INIT_LOG_FILE=/data/db/init-mongodb.log

start_mongod_as_daemon() {
echo 
echo "> start mongod ..."
echo 
mongod \
  --fork \
  --logpath ${INIT_LOG_FILE} \
  --quiet \
  --bind_ip 127.0.0.1 \
  --smallfiles;
}

create_user() {
if [ ! "$MONGO_INITDB_ROOT_USERNAME" ] || [ ! "$MONGO_INITDB_ROOT_PASSWORD" ]; then
  return
fi
echo 
echo "> create user ..."
echo 
mongo "${MONGO_INITDB_DATABASE}" <<-EOS
  db.createUser({
    user: "${MONGO_INITDB_ROOT_USERNAME}",
    pwd: "${MONGO_INITDB_ROOT_PASSWORD}",
    roles: [{ role: "root", db: "${MONGO_INITDB_DATABASE:-admin}" }]
  })
EOS
}

create_initialized_flag() {
echo 
echo "> create initialized flag file ..."
echo 
cat <<-EOF > "${INIT_FLAG_FILE}"
[$(date +%Y-%m-%dT%H:%M:%S.%3N)] Initialize scripts is finished.
EOF
}

stop_mongod() {
echo 
echo "> stop mongod ..."
echo 
mongod --shutdown;
}


# 
# Main process
# 
if [ ! -e ${INIT_FLAG_FILE} ]; then
  echo 
  echo "--- Initialize MongoDB --------------"
  echo 
  start_mongod_as_daemon
  create_user
  create_initialized_flag
  stop_mongod
fi

exec "$@"
