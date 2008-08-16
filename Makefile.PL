use inc::Module::Install;

name        'Log-Log4perl-Appender-Stomp';
all_from    'lib/Log/Log4perl/Appender/Stomp.pm';
author      'Adam Flott <adam@npjh.com>';

requires    'Log::Log4perl' => 0;
requires    'Net::Stomp'    => 0;

WriteAll;
