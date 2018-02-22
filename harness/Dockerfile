# This image is for testing the automation that configures the test harness
# Typically you'd do this on bare metal--rather than in docker

FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y software-properties-common

# install rvm
RUN apt-add-repository -y ppa:rael-gc/rvm \
 && apt-get update \
 && apt-get install -y rvm wget

# install ruby (rvm requires a login shell)
RUN /bin/bash -c "source /usr/share/rvm/scripts/rvm \
&& rvm install 2.5.0 \
&& gem install puppet"

# stage puppet repo
COPY modules/ /puppet/modules
COPY manifests/ /puppet/manifests

# install puppet packages
RUN /bin/bash -c "source /usr/share/rvm/scripts/rvm && puppet module install unibet-vagrant"
RUN /bin/bash -c "source /usr/share/rvm/scripts/rvm && puppet module install puppet-virtualbox"
RUN /bin/bash -c "source /usr/share/rvm/scripts/rvm && puppet module install puppetlabs-java"
RUN /bin/bash -c "source /usr/share/rvm/scripts/rvm && puppet module install puppetlabs-git"
RUN /bin/bash -c "source /usr/share/rvm/scripts/rvm && puppet apply /puppet/manifests/vmhost.pp"

# use a login shell for debugging (sources rvm)
ENTRYPOINT ["/bin/bash", "-l"]
