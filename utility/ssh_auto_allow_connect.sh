#!/bin/bash

# Список хостов (как у тебя)
HOSTS=(
fxprimus.mt4-report-mysql-replica-1
fxprimus.mt5report-mysql-prod-1
fxprimus.mysql-cs-prod-0
fxprimus.neo4j-members
fxprimus.mysql-prod-1
fxprimus.mt5report-mysql-staging-0
fxprimus.mysql-mt4report-staging-0
fxprimus.bastion-staging
fxprimus.mysql-staging-0
fxprimus.ws-proxy
fxprimus.mt5report-mysql-staging-1
fxprimus.mysql-staging-2
fxprimus.hrm-opcbiz
fxprimus.mysql-staging-1
fxprimus.mt5report-mysql-prod-0
fxprimus.mt5report-mysql-prod-2
fxprimus.neo4j-commissions
fxprimus.backup-staging
fxprimus.mt4-report-mysql-2
fxprimus.mt4-report-mysql-1
fxprimus.mysql-prod-0
fxprimus.mysql-prod-2
fxprimus.mysql-ndb-backup
)

for host in "${HOSTS[@]}"; do
  echo "Checking SSH connection and adding $host to known_hosts..."
  ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=~/.ssh/known_hosts "$host" exit
  if [[ $? -eq 0 ]]; then
    echo "$host - reachable and key added"
  else
    echo "$host - unreachable or connection failed"
  fi
done