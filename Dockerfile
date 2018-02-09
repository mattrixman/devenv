FROM ubuntu:16.04
COPY puppetlabs-release-pc1-xenial.deb /tmp/

RUN dpkg -i /tmp/puppetlabs-release-pc1-xenial.deb && apt-get update && apt-get -y install puppet && mkdir puppet

COPY modules/ /puppet/modules
COPY manifests/ /puppet/manifests
RUN puppet apply --modulepath /puppet/modules /puppet/manifests/site.pp

