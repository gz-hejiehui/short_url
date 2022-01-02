# php:8.0-fpm 的基础镜像为 debian 11
FROM php:8.0-fpm as php-fpm

# 工作目录
WORKDIR /var/www/html

# 安装扩展
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install --quiet --yes --no-install-recommends libzip-dev unzip \
    && docker-php-ext-install zip pdo pdo_mysql bcmath pcntl \
    && pecl install -o -f redis-5.3.4 \
    && docker-php-ext-enable redis

# 安装 composer
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# 添加用户 appuser，并指定容器以该用户执行程序
RUN groupadd --gid 1000 appuser \
    && useradd --uid 1000 -g appuser -G www-data,root --shell /bin/bash --create-home appuser
USER appuser
# -------------------------

# node
FROM node:16 as npm

RUN npm config set registry https://registry.npm.taobao.org

USER node
# -------------------------
