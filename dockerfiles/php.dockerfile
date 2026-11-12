FROM php:8.2.35-fpm-bookworm

ARG UID=1000
ARG GID=1000
ARG PROJECT_NAME

ENV UID=${UID}
ENV GID=${GID}
ENV APP_PATH=/var/www/html/${PROJECT_NAME}

COPY ./php/php.ini /usr/local/etc/php/php.ini

WORKDIR ${APP_PATH}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        libcurl4-openssl-dev \
        libpq-dev \
        libonig-dev \
        libxml2-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libwebp-dev \
        libxpm-dev \
        libfreetype6-dev \
        libzip-dev \
        libxrender1 \
        libxext6 \
        fontconfig \
        wkhtmltopdf \
        xvfb \
        fonts-dejavu \
        fonts-freefont-ttf \
        fonts-liberation \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install -j"$(nproc)" \
        curl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        mbstring \
        xml \
        zip \
        gd \
        exif \
        pcntl \
        bcmath \
        opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --system --gid "${GID}" laravel \
    && useradd --system \
        --uid "${UID}" \
        --gid "${GID}" \
        --shell /bin/sh \
        --create-home \
        laravel

RUN sed -i 's/^user = .*/user = laravel/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/^group = .*/group = laravel/' /usr/local/etc/php-fpm.d/www.conf \
    && echo 'php_admin_flag[log_errors] = on' >> /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p \
        ${APP_PATH}/storage \
        ${APP_PATH}/bootstrap/cache \
        /run/php \
    && chown -R laravel:laravel \
        ${APP_PATH} \
        /run/php

USER laravel

EXPOSE 9000

CMD ["php-fpm", "-F"]
