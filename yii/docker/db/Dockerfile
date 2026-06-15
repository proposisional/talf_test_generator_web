FROM mariadb:10.6

# Import inicial solo en el primer arranque (cuando /var/lib/mysql está vacío)
# El entrypoint oficial de MariaDB ejecuta *.sql en /docker-entrypoint-initdb.d
COPY tfg_talf.sql /docker-entrypoint-initdb.d/01-tfg_talf.sql
