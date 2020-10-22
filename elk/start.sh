#!/bin/bash

echo "syntax on
set number" > /root/.vimrc

cp /var/www/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
cp /var/www/elasticsearch/jvm.options /etc/elasticsearch/jvm.options
chown -R elasticsearch:elasticsearch /etc/elasticsearch
chown -R elasticsearch:elasticsearch /usr/share/elasticsearch
chsh -s /bin/bash elasticsearch
runuser -l elasticsearch -c '/usr/share/elasticsearch/bin/elasticsearch' &

echo "Waiting for Elastic Search..."
while ! curl --output /dev/null --silent --head --fail http://localhost:9200
do
    sleep 1
done
echo "Elastic Search is online"

ln -sf /var/www/logstash/logstash.conf /etc/logstash/conf.d/logstash.conf
/usr/share/logstash/bin/logstash --path.settings /etc/logstash &

ln -sf /var/www/kibana/kibana.yml /etc/kibana/kibana.yml
exec /usr/share/kibana/bin/kibana
