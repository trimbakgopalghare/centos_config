#
# Interface versions exposed by PHP:
# 
%php_core_api 20131106-64
%php_zend_api 20131226-64
%php_pdo_api  20080721-64
%php_version  5.6.33

%php_extdir    %{_libdir}/php/modules
%php_ztsextdir %{_libdir}/php-zts/modules

%php_inidir    %{_sysconfdir}/php.d
%php_ztsinidir %{_sysconfdir}/php-zts.d

%php_incldir    %{_includedir}/php
%php_ztsincldir %{_includedir}/php-zts/php

%__php         %{_bindir}/php
%__ztsphp      %{_bindir}/zts-php


