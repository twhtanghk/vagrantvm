FROM node

# vagrant
RUN apt-get update \
&&  env DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-kvm libvirt-bin ebtables dnsmasq libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev rsync nfs-kernel-server \
&&  apt-get clean \
&&  usermod -a -G libvirt-qemu root

ENV VAGRANT_VER=1.9.7
ENV VAGRANT_FILE=vagrant_${VAGRANT_VER}_x86_64.deb
ENV VAGRANT_URL=https://releases.hashicorp.com/vagrant/${VAGRANT_VER}/${VAGRANT_FILE}
RUN curl -O ${VAGRANT_URL} \
&&  dpkg -i ${VAGRANT_FILE} \
&&  rm ${VAGRANT_FILE} \
&&  vagrant plugin install vagrant-libvirt

# web app
ENV VER=${VER:-master} \
    REPO=https://github.com/twhtanghk/vagrantvm \
    APP=/usr/src/app

RUN git clone -b $VER $REPO $APP

WORKDIR $APP

RUN npm install \
&&  node_modules/.bin/bower install --allow-root

EXPOSE 1337                                                                     
                                                                                
ENTRYPOINT ./entrypoint.sh
