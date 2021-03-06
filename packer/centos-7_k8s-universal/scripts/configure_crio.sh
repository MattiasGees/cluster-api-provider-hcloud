#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

# install cri-o
cat << 'EOF' > /etc/yum.repos.d/crio.repo
[copr:copr.fedorainfracloud.org:simonswine:cri-o]
name=CRI-O Packages for EL 7
baseurl=https://raw.githubusercontent.com/simonswine/centos-cri-o-yum/master/epel-7
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/simonswine/cri-o/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF

yum -y install cri-o-1.16.6-2.el7 cri-tools yum-plugin-versionlock
rpm -q cri-o
yum versionlock add cri-o

# for some reason containers-common requires subscription manager, which we need to disable
cat > /etc/yum/pluginconf.d/subscription-manager.conf <<EOF
[main]
enabled=0
EOF

# remove default CNIs
rm -f /etc/cni/net.d/100-crio-bridge.conf /etc/cni/net.d/200-loopback.conf

# add default cni directory the config
perl -i -0pe 's#plugin_dirs\s*=\s*\[[^\]]*\]#plugin_dirs = [\n  "/opt/cni/bin",\n  "/usr/libexec/cni"\n]#g' /etc/crio/crio.conf

# enable systemd service after next boot
systemctl enable crio.service

