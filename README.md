collectd-pkgbuild
=================

This builds a recent version of collectd for CentOS/RHEL 6 and packages it as RPM. 

Collectd, https://collectd.org/, grabs all kinds of metrics and saves them or sends them on.

We use it to collect low level system metrics: cpu, memory, network, disk. Think sar.  
We send it to graphite so we can create dashboards, have nagios alerts, etc.

We also collect Oracle DBMS metrics to get a better view on what it is doing (wrong).  
More info at: https://collectd.org/wiki/index.php/Plugin:Oracle

EPEL already has collectd packages but they didn´t work for us because:
- It's an ancient version without write_graphite and many other cool new features.
- The Oracle plugin is not included.


Building
--------

The build script needs the following before it will work.
- vagrant
- a CentOS vagrant box
- Oracle RPMS
- collectd source RPM

1. Vagrant

  I run vagrant on Ubuntu but other Linux or OS-X should work fine.  
  Get an recent version at http://vagrantup.com

2. CentOS vagrant box

  I use the one from Chef bento project https://github.com/opscode/bento  
  CentOS box:
  `vagrant box add chef/centos-6.5 http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box`

3. Download ora instant client and devel RPMs

  The packages are proprietary and behind a login wall.

  You can find the packages at:
    http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html

  You'll need a OTN logon which you probably have if you have to run Oracle software.

  Grab the oracle-instantclient -basic(lite) and -devel RPMs and place them in the same folder as where the Vagrantfile sits.

4. Get the fedora source RPM for collectd

  This is kept up to date but for the latest version of fedora and not EL of course.  
  https://admin.fedoraproject.org/pkgdb/acls/name/collectd  
  I used this one:  
  `curl -O http://kojipkgs.fedoraproject.org//packages/collectd/5.4.1/2.fc21/src/collectd-5.4.1-2.fc21.src.rpm`

5. Go, go, go build

    `vagrant up`

  If all goes well it will:
  - set up the centos box
  - get additional packages the collectd build depends on
  - rpmbuild collectd
  - copy the resulting RPMs in ./rpms/ directory

  To clean up:  
    `vagrant destroy`

6. Use the RPMs

  Install them directly or put them in your local yum repo and let your configuration management tooling do the lifting.


Oracle plugin configuration
---------------------------

1. Add a monitor user to oracle

  `<example sql statement here>`

2. Add environment variables to collectd startup

  in /etc/default/collectd:
```
# changes the paths to your local settings
export ORACLE_HOME=/opt/oracle/1120
export LD_LIBRARY_PATH=/opt/oracle/1120/lib
export TNS_ADMIN=/opt/oracle/tnsadmin
```    
3. Create a /etc/collectd.d/oracle.conf

  Example at https://collectd.org/wiki/index.php/Plugin:Oracle  
  We use:  
  `<WiP>`


Licenses
--------

Collectd is GPL, some plugins are under other open licenses. 

Oracle RPMs are proprietary Oracle license.

collectd-oracle plugin is GPL with exception clause to allow linking with closed source.  
https://collectd.org/wiki/index.php/Plugin:Oracle

This little build project is under the ASL:

```
Copyright 2014, Gerard de Vos (gerard@de-vos.net)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
