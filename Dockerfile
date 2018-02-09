FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y software-properties-common

# install rvm
RUN apt-add-repository -y ppa:rael-gc/rvm \
 && apt-get update \
 && apt-get install -y rvm

# install ruby (rvm requires a login shell)
RUN /bin/bash -l -c "source /usr/share/rvm/scripts/rvm && rvm install 2.5.0"

# install puppet
RUN /bin/bash -l -c "gem install puppet"

# stage puppet repo
COPY modules/ /puppet/modules
COPY manifests/ /puppet/manifests
COPY Puppetfile /puppet/Puppetfile

# install puppet packages
RUN /bin/bash -l -c "cd /puppet \
 && puppet module install puppetlabs-java --version 2"

# let puppet handle the rest
RUN /bin/bash -l -c "puppet apply /puppet/manifests/site.pp"

# use a login shell for debugging
ENTRYPOINT ["/bin/bash", "-l"]
