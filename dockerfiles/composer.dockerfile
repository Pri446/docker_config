FROM composer:2 AS composer_source

FROM php:8.2.35-cli-bookworm

ARG UID=1000
ARG GID=1000
ARG PROJECT_NAME

ENV UID=${UID}
ENV GID=${GID}
ENV APP_PATH=/var/www/html/${PROJECT_NAME}

COPY --from=composer_source /usr/bin/composer /usr/local/bin/composer

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        unzip \
        libpq-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
        libcurl4-openssl-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libwebp-dev \
        libfreetype6-dev \
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
        bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --system --gid "${GID}" laravel \
    && useradd --system \
        --uid "${UID}" \
        --gid "${GID}" \
        --shell /bin/sh \
        --create-home \
        laravel

WORKDIR ${APP_PATH}

RUN chown -R laravel:laravel ${APP_PATH}

USER laravel
RUN git config --global --add safe.directory ${APP_PATH}
ENTRYPOINT ["composer"]
