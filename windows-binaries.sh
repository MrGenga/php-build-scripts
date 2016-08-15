#!/bin/bash

# Requirements: curl, bsdtar

set -e

PHP_VERSION="7.0.9"
PHP_VERSION_BASE="${PHP_VERSION:0:3}"
EXTENSIONS="pthreads weakref yaml"
pthreads_VERSION="3.1.6"
weakref_VERSION="0.3.2"
yaml_VERSION="2.0.0RC7"

get () {
    echo "Downloading and extracting ${1}..."
    curl -fsSL "${1}" | bsdtar -xf - -C "work/${2}"
    echo "${1} downloaded and extracted."
}

pack () {
    echo "Archiving files..."
    bsdtar -acf "${1}" -C work .
    echo "Compressed archive can be found at ${1}."
}

for ARCH in x86 x64; do
    mkdir -p work
    mkdir -p work/bin/php
    get "http://windows.php.net/downloads/releases/php-${PHP_VERSION}-Win32-VC14-${ARCH}.zip" bin/php &
    for EXT in $EXTENSIONS; do
        EXT_VER_TEMP="${EXT}_VERSION"
        EXT_VER="${!EXT_VER_TEMP}"
        get "http://windows.php.net/downloads/pecl/releases/${EXT}/${EXT_VER}/php_${EXT}-${EXT_VER}-${PHP_VERSION_BASE}-ts-vc14-${ARCH}.zip" bin/php &
    done
    echo ";Custom Genisys php.ini file
zend.enable_gc = On
max_execution_time = 0
error_reporting = -1
display_errors = stderr
display_startup_errors = On
register_argc_argv = On
default_charset = \"UTF-8\"
include_path = \".;.\ext\"
extension_dir = \"./\"
enable_dl = On
allow_url_fopen = On
extension=php_bz2.dll
extension=php_weakref.dll
extension=php_curl.dll
extension=php_mysqli.dll
extension=php_sqlite3.dll
extension=php_sockets.dll
extension=php_mbstring.dll
extension=php_yaml.dll
extension=php_pthreads.dll
extension=php_com_dotnet.dll
extension=php_openssl.dll
zend_extension=php_opcache.dll
;zend_extension=php_xdebug.dll
cli_server.color = On
phar.readonly = Off
phar.require_hash = On
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.save_comments=1
opcache.load_comments=1
opcache.fast_shutdown=0
opcache.optimization_level=0xffffffff
" > work/bin/php/php.ini
    wait
    pack "php_${PHP_VERSION}_${ARCH}.zip"
    rm -rf work
done
