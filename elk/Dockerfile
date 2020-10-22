FROM centos:7

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

COPY elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

RUN yum install -y vim curl net-tools lsof iputils-ping \
    java-1.8.0-openjdk initscripts elasticsearch-6.3.1 logstash kibana-6.3.1 \
    && yum clean all


RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu

RUN ln -s /dev/null /etc/systemd/system/systemd-sysctl.service

RUN mkdir /usr/share/elasticsearch/data && chown -R elasticsearch:elasticsearch /usr/share/elasticsearch

WORKDIR /var/www