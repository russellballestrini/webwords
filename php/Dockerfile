FROM php:8.1-apache

COPY index.php /var/www/html/

EXPOSE 80

RUN echo "Listen 31337" >> /etc/apache2/ports.conf && \
    echo "<VirtualHost *:31337>" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    DocumentRoot /var/www/html" >> /etc/apache2/sites-available/000-default.conf && \
    echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf

EXPOSE 31337

CMD ["apache2-foreground"]