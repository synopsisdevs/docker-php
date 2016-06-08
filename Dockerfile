FROM php:7-apache

MAINTAINER developers@synopsis.cz

RUN curl -fsSL https://get.docker.com/ | sh

RUN usermod -aG docker www-data
