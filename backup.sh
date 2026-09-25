#!/usr/bin/env bash
set -e
cd /opt/open-webui

# 1. Secret (.env) chiffré à part
if [ -f .env ]; then
    gpg --batch --yes --passphrase-file /root/.backup_passphrase \
        -c --cipher-algo AES256 -o env.gpg .env
fi

# 2. Données Open WebUI (conversations, comptes) chiffrées
if [ -d data ]; then
    tar czf - data 2>/dev/null | \
        gpg --batch --yes --passphrase-file /root/.backup_passphrase \
            -c --cipher-algo AES256 -o data.tar.gz.gpg
fi

# 3. Commit + push de la config (thème, compose, backup.sh)
git add -A
git commit -m "Sauvegarde Open WebUI $(date '+%F %H:%M')" || true
git push 2>/dev/null || echo "[i] Pas de remote configuré (push ignoré)"
echo "[✓] Sauvegarde Open WebUI terminée."
