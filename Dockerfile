FROM node

# vagrant
RUN echo "deb http://download.virtualbox.org/virtualbox/debian jessie contrib" >/etc/apt/sources.list.d/virtualbox.list \
&&  curl -O https://www.virtualbox.org/download/oracle_vbox_2016.asc \
&&  apt-key add oracle_vbox_2016.asc

RUN apt-get update \
&&  apt-get install -y vagrant virtualbox-5.1 \
&&  apt-get clean


# web app
ENV VER=${VER:-master} \
    REPO=https://github.com/twhtanghk/vagrantvm \
    APP=/usr/src/app

RUN git clone -b $VER $REPO $APP

WORKDIR $APP

RUN npm install

EXPOSE 1337                                                                     
                                                                                
ENTRYPOINT ./entrypoint.sh
