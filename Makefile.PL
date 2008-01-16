use strict;
use inc::Module::Install;

name('GunghoX-DeepCrawler');
all_from('lib/GunghoX/DeepCrawler.pm');

requires 'POE';
requires 'Swarmage', '0.01003';
requires 'Gungho', '0.09006';
requires 'GunghoX::FollowLinks', '0.00005';

auto_install;
WriteAll;