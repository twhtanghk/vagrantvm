FROM node

RUN apt-get update \
&&  apt-get install -y vagrant \
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
