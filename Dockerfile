FROM php:8.1-apache

WORKDIR /var/www/html/sammy-php
# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    default-mysql-client \
    nano  
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Apache2
RUN apt-get install apache2
COPY sammy_project.conf /etc/apache2/sites-available
# Copy existing application directory contents
COPY .env .
COPY . .
RUN rm -rf /etc/apache2/sites-available/000-default.conf
RUN a2ensite sammy_project.conf
RUN a2enmod rewrite
# Install MySQL
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN chmod +x /usr/local/bin/composer

# Install required PHP extensions for Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd
RUN docker-php-ext-install gd

# Copy existing application directory contents

#COPY web.php /routes
#COPY student.blade.php /resources/views
RUN chgrp -R www-data /var/www/html/sammy-php
RUN chmod -R 775 /var/www/html/sammy-php/storage
RUN chown -R www-data:www-data /var/www/html/sammy-php

#RUN php artisan optimize:clear
#RUN php artisan migrate
# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
