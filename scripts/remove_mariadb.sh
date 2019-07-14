#!/usr/bin/env bash

# MariaDB uninstaller
# Min. Requirement  : GNU/Linux Ubuntu 14.04
# Last Build        : 12/07/2019
# Author            : ESLabs.ID (eslabs.id@gmail.com)
# Since Version     : 1.0.0

# Include decorator
BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

if [ "$(type -t run)" != "function" ]; then
    . ${BASEDIR}/helper.sh
fi

# Make sure only root can run this installer script
if [ $(id -u) -ne 0 ]; then
    error "You need to be root to run this script"
    exit 1
fi

function init_mariadb_removal() {
    # Stop MariaDB mysql server process
    if [[ $(ps -ef | grep -v grep | grep mysqld | wc -l) > 0 ]]; then
        run service mysql stop
    fi

    run apt-get --purge remove -y mariadb-server libmariadbclient18 >> lemper.log 2>&1
    #run apt-get purge -y mariadb-server libmariadbclient18 >> lemper.log 2>&1

    # Remove repo
    run rm -f /etc/apt/sources.list.d/MariaDB-*.list

    # Remove MariaDB (MySQL) config files
    while [[ $REMOVE_MYSQLCONFIG != "y" && $REMOVE_MYSQLCONFIG != "n" ]]; do
        read -p "Remove MariaDB (MySQL) database and configuration files \
        (This action is not reversible)? [y/n]: " -e REMOVE_MYSQLCONFIG
    done
    if [[ "$REMOVE_MYSQLCONFIG" == Y* || "$REMOVE_MYSQLCONFIG" == y* ]]; then
        echo "All your SQL database and configuration files deleted permanently."
        if [[ -d /etc/mysql ]]; then
            run rm -fr /etc/mysql
        fi
        if [[ -d /var/lib/mysql ]]; then
            run rm -fr /var/lib/mysql
        fi
    fi

    if [[ -z $(which mysql) ]]; then
        status "MariaDB (MySQL) server removed."
    fi
}

echo -e "\nUninstalling MariaDB (MySQL)..."
if [[ -n $(which mysql) ]]; then
    init_mariadb_removal "$@"
else
    warning -e "MariaDB installation not found."
fi