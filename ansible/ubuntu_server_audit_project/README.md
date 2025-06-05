# Ansible Ubuntu Audit

## Описание
Выполняет аудит серверов Ubuntu 18.04 через Ansible. Скрипт запускается от имени пользователя с `sudo`, результаты сохраняются в `./logs/`.

## Структура
- `inventory.ini` — список серверов (по DNS-алиасам)
- `audit.sh` — bash-скрипт аудита
- `run_audit.yml` — playbook Ansible
- `logs/` — папка с логами после запуска

## Запуск
```bash
ansible-playbook -i inventory.ini run_audit.yml
```
