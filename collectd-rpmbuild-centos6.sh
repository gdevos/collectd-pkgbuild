#!/bin/bash
#
# This script is part of the collectd-pkgbuild vagrant project and meant to be run as a shell provisioner.
# You´re free to use it for anything you want though :)
#
echo "## Starting provision run"

bailout() {
  echo $1
  echo \n
  echo "Script could not complete. Please see the README and/or use \"vagrant ssh\" to find out more."
  echo "Good luck!"
  exit 1
}

echo "## Go fetch dependencies"
echo "## Oracle RPMs:"
cd /vagrant
INSTANTCLIENT=`ls oracle-instantclient12*rpm | grep -v devel`

[ "$INSTANTCLIENT" == "" ] && bailout "No Oracle instant client RPM found, exiting..."
if ! rpm -qa | grep -v devel | grep -q oracle-instantclient; then
  echo "## Installing $INSTANTCLIENT"
  yum -y install $INSTANTCLIENT  || bailout "Could not install $INSTANTCLIENT"
else
  echo "$INSTANTCLIENT already installed"
fi

IC_DEVEL=`ls oracle-instantclient12*devel*`

[ "$IC_DEVEL" == "" ] && bailout "No Oracle instant client development RPM found, exiting..."

if ! rpm -qa | grep instantclient | grep -q devel; then
  # the devel rpm has no real dependencies but it is build with a dep to the full basic client RPM, not lite
  echo "## Installing $IC_DEVEL"
  rpm -i --nodeps $IC_DEVEL || bailout "Could not install $IC_DEVEL"
else
  echo "instantclient devel already installed"
fi


echo "## Some build tools"

# EPEL repo
rpm -qa | grep -q epel-release-6-8 || yum -y install http://mirror.nl.leaseweb.net/epel/6/i386/epel-release-6-8.noarch.rpm || bailout "Could not set up EPEL, exiting..."

# rpm-build & friends 
yum -y install rpm-build yum-utils gcc || bailout "Could not install rpmbuildtools"

# collectd SRPM, from /vagrant for now
CSRPM=`ls collectd*src.rpm`

[ "$CSRPM" == "" ] && bailout "No collectd src rpm found, exiting..."

rpm -i $CSRPM || bailout "Could not install $CSRPM"

# srpm installed to users homedir, not /usr/src. I must be using too ancient versions of RH
cd ~/rpmbuild

echo "## Patch .spec file for EL6 specifics and oracle plugin"
patch SPECS/collectd.spec < /vagrant/collectd.spec.el6.patch || bailout "Could not apply EL6 .spec patch"

echo "## Installing all dependencies according to .spec file"
yum-builddep -y SPECS/collectd.spec || bailout "Could not fetch collectd build dependencies.."

echo "## Funky ora paths. make some links"
cd /usr/lib/oracle/12.1/client64/
mkdir rdbms
cd rdbms
sudo ln -s /usr/include/oracle/12.1/client64 public

echo "## Lets build!"
cd ~/rpmbuild
export ORACLE_HOME=/usr/lib/oracle/12.1/client64
rpmbuild -bb SPECS/collectd.spec || bailout "Could not build collectd RPMs"

echo "## Copying RPMs to vagrant dir"
mkdir /vagrant/rpms/
cp -rv RPMS/x86_64/*rpm /vagrant/rpms/ 


echo "## Done! I didn't think we'd make it this far ;)"
