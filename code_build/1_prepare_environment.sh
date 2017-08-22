#!/bin/bash
add-apt-repository -y ppa:webupd8team/java \
&& apt-get update \
&& echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true \
   | /usr/bin/debconf-set-selections \
&& apt-get install -y --allow-unauthenticated software-properties-common \
     wget maven tzdata net-tools curl iputils-ping iotop iftop tcpdump lsof htop iptraf \
     oracle-java8-installer oracle-java8-unlimited-jce-policy \
&& printf '2\n37\n' | dpkg-reconfigure -f noninteractive tzdata \
