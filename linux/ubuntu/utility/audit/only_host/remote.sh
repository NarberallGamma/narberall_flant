#!/bin/bash

USER="p.zakharevich"
SUDO_PASS="@Pachundris899!"  # <-- сюда пароль sudo впиши вручную (не безопасно хранить так, лучше использовать vault)
LOCAL_AUDIT_SCRIPT="./ubuntu_audit.sh" # Путь к локальному скрипту аудита
REMOTE_PATH="//home/flant/p.zakharevich/ubuntu_audit.sh"
LOG_DIR="./logs"

HOSTS=(
  "fxprimus.mt4-report-mysql-replica-1"
  "fxprimus.mt5report-mysql-prod-1"
  "fxprimus.mysql-cs-prod-0"
  "fxprimus.neo4j-members"
  "fxprimus.mysql-prod-1"
  "fxprimus.mt5report-mysql-staging-0"
  "fxprimus.mysql-mt4report-staging-0"
  "fxprimus.bastion-staging"
  "fxprimus.mysql-staging-0"
  "fxprimus.ws-proxy"
  "fxprimus.mt5report-mysql-staging-1"
  "fxprimus.mysql-staging-2"
  "fxprimus.hrm-opcbiz"
  "fxprimus.mysql-staging-1"
  "fxprimus.mt5report-mysql-prod-0"
  "fxprimus.mt5report-mysql-prod-2"
  "fxprimus.neo4j-commissions"
  "fxprimus.backup-staging"
  "fxprimus.mt4-report-mysql-2"
  "fxprimus.mt4-report-mysql-1"
  "fxprimus.mysql-prod-0"
  "fxprimus.mysql-prod-2"
  "fxprimus.mysql-ndb-backup"
)

mkdir -p "$LOG_DIR"

check_host() {
  local host=$1
  ssh -o BatchMode=yes -o ConnectTimeout=5 ${USER}@${host} "echo 2>&1" && return 0 || return 1
}

for host in "${HOSTS[@]}"; do
  echo "Проверяем доступность $host..."
  if check_host "$host"; then
    echo "$host доступен. Копируем скрипт..."
    sshpass -p "$SUDO_PASS" scp "$LOCAL_AUDIT_SCRIPT" "${USER}@${host}:${REMOTE_PATH}"
    
    echo "Запускаем скрипт с sudo на $host..."
    # Команда запуска с sudo, передача пароля через sshpass и sudo -S
    sshpass -p "$SUDO_PASS" ssh -o BatchMode=yes "${USER}@${host}" \
      "echo '$SUDO_PASS' | sudo -S bash $REMOTE_PATH > /tmp/audit_${host}.log 2>&1 & echo \$! > /tmp/audit_${host}.pid"
    
    echo "Ждём 10 секунд после запуска..."
    sleep 10
    
    echo "Забираем лог с $host ..."
    sshpass -p "$SUDO_PASS" scp "${USER}@${host}:/tmp/audit_${host}.log" "$LOG_DIR/audit_${host}.log"
    
  else
    echo "Внимание! $host недоступен, пропускаем."
  fi
done

echo "Все операции завершены."
