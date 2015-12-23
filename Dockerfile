FROM centos:6
MAINTAINER Nhan Nguyen <nxtnhan@gmail.com>
RUN yum -y update

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
# Install build tools
RUN yum -y install gcc-c++ pcre-devel zlib-devel make unzip 
RUN rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
# Install PHP 7
RUN yum -y install --enablerepo=webtatic php70w php70w-common php70w-fpm php70w-cli php70w-opcache php70w-pear php70w-devel php70w-intl php70w-mbstring php70w-mcrypt
# Install Git latest  
RUN yum -y install curl-devel expat-devel gettext-devel openssl openssl-devel zlib-devel bzip2


# V8 required Git >=2.2.5, but current version is only 1.7.1, so we need to build Git latest version
RUN yum -y install gcc perl-ExtUtils-MakeMaker git tar wget
RUN git --version

RUN cd /usr/src && \
    git clone https://github.com/git/git
RUN cd /usr/src/git && make prefix=/usr/local/git all && make prefix=/usr/local/git install
RUN yum -y remove git

# Use new Git
env PATH /usr/local/git/bin:$PATH
RUN git --version

# Install Python 2.7

RUN cd /usr/src && wget --no-check-certificate https://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz
RUN cd /usr/src && tar xf Python-2.7.6.tgz
RUN cd /usr/src/Python-2.7.6 && ./configure --prefix=/usr/local
RUN cd /usr/src/Python-2.7.6 && make && make altinstall
RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python

# Install Depot Tools
RUN cd /usr/src && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
env PATH /usr/src/depot_tools:$PATH


# Fetch v8
RUN cd /usr/src && fetch v8

# Upgrade GCC to 4.8.5
RUN yum install -y texinfo-tex flex zip libgcc.i686 glibc-devel.i686
RUN cd /usr/src && wget ftp://ftp.gnu.org/gnu/gcc/gcc-4.8.5/gcc-4.8.5.tar.gz
RUN tar -xvf gcc-4.8.5.tar.gz
RUN cd gcc-4.8.5
RUN ./contrib/download_prerequisites
RUN cd /usr/src && mkdir gcc-build-4.8.5
RUN cd gcc-build-4.8.5
RUN ../configure --prefix = / usr
RUN make && make install

# Build V8
RUN cd /usr/src/v8 && make native library=shared snapshot=off -j 4

# Copy to lib directory
RUN cp -R /usr/src/v8/out/native/lib.target/lib* /lib64/
#RUN cp /usr/src/v8/out/native/obj.target/tools/gyp/libv8_libplatform.a /usr/lib64/
RUN echo -e "create /usr/lib/libv8_libplatform.a\naddlib  /usr/src/v8/out/native/obj.target/tools/gyp/libv8_libplatform.a\nsave\nend" | ar -M
RUN cp -R /usr/src/v8/include /usr/local

# Install v8js
RUN echo "/usr/lib64" | pecl install v8js-1.0.0 

ENV NO_INTERACTION 1
RUN echo extension=v8js.so > /etc/php.d/v8js.ini
RUN php -m | grep v8

# Check V8Js class
RUN php -r 'var_dump(get_declared_classes());' | grep V8
RUN php -r '$class = new ReflectionClass("V8Js"); var_dump($class->getMethods());'

# Excute test v8js
RUN php -r '$v8 = new V8Js(); var_dump($v8->executeString("1+2+3"));'


# Install Nginx Latest
ADD nginx.repo /etc/yum.repos.d/nginx.repo
RUN yum -y install nginx

# Config server
ADD nginx.conf /etc/nginx/nginx.conf
# Start web server

ADD start.sh /start.sh
ADD index.html /index.html
ADD test.php /test.php

VOLUME ["/website_files"]
EXPOSE 80
CMD ["sh", "/start.sh"]