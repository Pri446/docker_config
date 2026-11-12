FROM nginx:stable-alpine

ARG UID=1000
ARG GID=1000
ARG PROJECT_NAME

ENV UID=${UID}
ENV GID=${GID}
ENV APP_PATH=/var/www/html/${PROJECT_NAME}

RUN addgroup --system --gid "${GID}" laravel \
    && adduser --system \
        --uid "${UID}" \
        --ingroup laravel \
        --no-create-home \
        --shell /sbin/nologin \
        laravel \
    && sed -i 's/user  nginx/user  laravel/' /etc/nginx/nginx.conf

COPY ./nginx/default.conf.template /etc/nginx/templates/default.conf.template

EXPOSE 80
