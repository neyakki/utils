#!/usr/bin/env bash

WORK_EMAIL=""
WORK_NAME=""
PERSONAL_EMAIL=""
PERSONAL_NAME=""

case $1 in
    "-w" | "--work")
        OLD_EMAIL=$PERSONAL_EMAIL
        CORRECT_NAME=$WORK_NAME
        CORRECT_EMAIL=$WORK_EMAIL
        ;;
    "-p" | "--personal")
        OLD_EMAIL=$WORK_EMAIL
        CORRECT_NAME=$PERSONAL_NAME
        CORRECT_EMAIL=$PERSONAL_EMAIL
        ;;
    *)
        echo "Использование: $0 {-w|--work} | {-p|--personal}"
        echo "  -w, --work     : Заменить личную почту на рабочую"
        echo "  -p, --personal : Заменить рабочую почту на личную"
        exit 1
        ;;
esac

echo "Change: $OLD_EMAIL -> $CORRECT_NAME <$CORRECT_EMAIL>"

# Проверка наличия git-filter-repo
if command -v git-filter-repo >/dev/null 2>&1; then
    echo "[INFO] Using git-filter-repo 'git-filter-repo'"
    
    # Используем git-filter-repo
    git-filter-repo --email-callback "
	email = email.decode()
	if email == b'$OLD_EMAIL':
	    return b'$CORRECT_NAME <$CORRECT_EMAIL>'
	return email
	" --force

else
    echo "[INFO] 'git-filter-repo' not found. Using deprecated 'git filter-branch'."

    # Экспортируем переменные для подпроцесса filter-branch
    export OLD_EMAIL
    export CORRECT_NAME
    export CORRECT_EMAIL
    
    # Скрываем предупреждение о устаревании filter-branch
    export FILTER_BRANCH_SQUELCH_WARNING=1

    git filter-branch --force --env-filter '
    if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
    then
        export GIT_COMMITTER_NAME="$CORRECT_NAME"
        export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
    fi
    if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
    then
        export GIT_AUTHOR_NAME="$CORRECT_NAME"
        export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
    fi
    ' --tag-name-filter cat -- --all
fi

echo "[INFO] The author's change was completed successfully"
