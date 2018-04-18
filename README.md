DOCKER Centos - V8JS
===============

- CentOS 7
- Nginx 1.9.9
- PHP 7
- V8
- V8JS

## Download
`sudo docker pull virusvn/docker-centos-v8js:nginx-php-fpm`

`nginx-php-fpm` is the tag of current build

## Run
`sudo docker run -i -t  virusvn/docker-centos-v8js:nginx-php-fpm /bin/bash`

After the above command, you will be logged in and see something like this:

`[root@c713a8de0687 /]#`

You can interactive with this container by execute some javascript from php

`php -r 'var_dump(get_declared_classes());' | grep V8`

`php -r '$class = new ReflectionClass("V8Js"); var_dump($class->getMethods());'`

`php -r '$v8 = new V8Js(); var_dump($v8->executeString("1+2+3"));'`
