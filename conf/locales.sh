#!/bin/bash

sed --regexp-extended --expression='

   1  {
         i\
# This file lists locales that you wish to have built. You can find a list\
# of valid supported locales at /usr/share/i18n/SUPPORTED, and you can add\
# user defined locales to /usr/local/share/i18n/SUPPORTED. If you change\
# this file, you need to rerun locale-gen.\
\


      }

   /^([[:lower:]]+)(_[[:upper:]]+)?(\.UTF-8)?(@[^[:space:]]+)?[[:space:]]+UTF-8$/!   s/^/# /

' /usr/share/i18n/SUPPORTED >  /etc/locale.gen

debconf-set-selections <<< 'locales locales/default_environment_locale select 1'

rm --force --verbose /etc/default/locale

dpkg-reconfigure --frontend=noninteractive locales