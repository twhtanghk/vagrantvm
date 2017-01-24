FROM node

# vagrant
RUN echo "deb http://download.virtualbox.org/virtualbox/debian jessie contrib" >/etc/apt/sources.list.d/virtualbox.list \
&&  curl -O https://www.virtualbox.org/download/oracle_vbox_2016.asc \
&&  apt-key add oracle_vbox_2016.asc

RUN apt-get update \
&&  apt-get install -y virtualbox-5.1 rsync \
&&  apt-get clean

RUN curl -O https://releases.hashicorp.com/vagrant/1.9.1/vagrant_1.9.1_x86_64.deb \
&&  dpkg -i vagrant_1.9.1_x86_64.deb \
&&  rm vagrant_1.9.1_x86_64.deb

# web app
ENV VER=${VER:-master} \
    REPO=https://github.com/twhtanghk/vagrantvm \
    APP=/usr/src/app

RUN git clone -b $VER $REPO $APP

WORKDIR $APP

RUN npm install

EXPOSE 1337                                                                     
                                                                                
ENTRYPOINT ./entrypoint.sh
