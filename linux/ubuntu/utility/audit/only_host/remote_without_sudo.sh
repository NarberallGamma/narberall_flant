#!/bin/bash

USER="p.zakharevich"
LOCAL_AUDIT_SCRIPT="./ubuntu_audit.sh"               # Локальный скрипт аудита
REMOTE_PATH="/home/flant/p.zakharevich/remote_audit.sh"  # Путь на целевом хосте
LOG_DIR="./logs"                                     # Локальная папка для логов

# Хосты
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

for HOST in "${HOSTS[@]}"; do
  echo "Проверяем доступность $HOST..."

  if ssh -o BatchMode=yes -o ConnectTimeout=10 "$USER@$HOST" "exit" &>/dev/null; then
    echo "$HOST доступен. Копируем скрипт..."
    scp "$LOCAL_AUDIT_SCRIPT" "$USER@$HOST:$REMOTE_PATH"
    if [ $? -ne 0 ]; then
      echo "Ошибка копирования скрипта на $HOST, пропускаем."
      continue
    fi

    echo "Запускаем скрипт без sudo на $HOST (не требуется ввод пароля sudo)..."
    ssh "$USER@$HOST" "chmod +x $REMOTE_PATH && $REMOTE_PATH > /tmp/audit_\$(hostname).log 2>&1"
    if [ $? -ne 0 ]; then
      echo "Ошибка при запуске скрипта на $HOST."
      continue
    fi

    echo "Ждём 10 секунд после запуска..."
    sleep 10

    echo "Забираем лог с $HOST ..."
    scp "$USER@$HOST:/tmp/audit_${HOST}.log" "$LOG_DIR/audit_${HOST}.log"
    if [ $? -ne 0 ]; then
      # Если не нашли файл с именем audit_${HOST}.log, попробуем взять по имени хоста удалённого (hostname)
      echo "Не удалось найти лог с именем audit_${HOST}.log, пробуем audit_$(ssh $USER@$HOST hostname).log"
      REMOTE_HOSTNAME=$(ssh "$USER@$HOST" hostname)
      scp "$USER@$HOST:/tmp/audit_${REMOTE_HOSTNAME}.log" "$LOG_DIR/audit_${HOST}.log"
      if [ $? -ne 0 ]; then
        echo "Ошибка при получении лога с $HOST."
      else
        echo "Лог успешно сохранён: $LOG_DIR/audit_${HOST}.log"
      fi
    else
      echo "Лог успешно сохранён: $LOG_DIR/audit_${HOST}.log"
    fi
  else
    echo "$HOST недоступен, пропускаем."
  fi

  echo
done

echo "Все операции завершены."