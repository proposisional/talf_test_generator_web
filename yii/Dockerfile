FROM php:8.3-apache

ENV DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar paquetes base y drivers de BBDD
RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip curl ca-certificates pkg-config \
    libicu-dev libzip-dev zlib1g-dev libonig-dev libpq-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install pdo_mysql pdo_pgsql intl mbstring zip \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Instalar Octave y Gnuplot
RUN apt-get update \
    && apt-get install -y octave gnuplot-nox \
    && rm -rf /var/lib/apt/lists/*

# Instalar Graphviz
RUN apt-get update && apt-get install -y graphviz && rm -rf /var/lib/apt/lists/*

# Configurar Apache para usar /var/www/html/web como DocumentRoot y permitir .htaccess
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/web#' /etc/apache2/sites-available/000-default.conf \
    && printf "<Directory /var/www/html/web>\n    AllowOverride All\n    Require all granted\n</Directory>\n" > /etc/apache2/conf-available/yii.conf \
    && a2enconf yii

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV OCTAVE_BIN=/usr/bin/octave \
    APP_ENV=prod

WORKDIR /var/www/html

# Copiar el código de la app (en Render no hay volumen, así que si no copiamos el repo
# dentro de la imagen, no existirá composer.json en /var/www/html)
COPY . /var/www/html

# Copiar entrypoint
COPY docker/entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
