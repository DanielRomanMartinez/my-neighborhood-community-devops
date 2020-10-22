My Neighborhood Community  Devops: Docker infrastructure to run API and Backoffice in your local environment

## Stack
* PHP 7.4
* Nginx 1.15
* MariaDB 10.4
* RabbitMQ

## 🚀 Environment setup
* Clone this repository: `git clone git@github.com:DanielRomanMartinez/my-neighborhood-community-api.git`
* Move to project folder: `cd devops`
* Clone repository: `make api-prepare`
* Start enviroment: `make start`
* Build api: `make api-install`
* Stop environment: `make stop`
* Rebuild environment: `make rebuild`

### ElasticSearch
* Create _action_logs_ index: `make es-index`

### API
* Setup API (download API code, install dependencies and rebuild DB): `make api-setup`
* Update code and database: `make api-update`
* Run tests: `make api-test`

### Adding hostnames

Docker containers' IP change when you build them, so you have to edit your *hosts* file after building docker.

#### Using Makefile command
* GNU/Linux: `make sites`
* MacOS: `make sites e=mac`

#### Manually

* GNU/Linux:
```
echo "$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' neighborhood.api) local-api.my-neighborhood-community.com"| sudo tee -a /etc/hosts > /dev/null
```

* MacOS:
```
echo "127.0.0.1 local-api.my-neighborhood-community.com"| sudo tee -a /etc/hosts > /dev/null
```

## Adminer

Access database via adminer

http://local-api.my-neighborhood-community.com:8088

## RabbitMQ

http://localhost:15672

**Access** RabbitMQ

**User:** rabbitmq

**Password:** rabbitmq


### Redis Commander

http://localhost:8081

**Server Type:** Standalone Redis-Server

**Hostname:** redis

**Port:** 6379

### ELK

**Elastic:** http://localhost:9200

**Kibana:** http://localhost:5601

**Configuration:** change files and restart containers.


### SSL Certificate
* In order to have a valid ssl certificate, you should import the [rootCA certificate](etc/infrastructure/certificate/rootCA.pem) on your browser. Setting up following: https://code.luasoftware.com/tutorials/nginx/self-signed-ssl-for-nginx-and-chrome/

### Debugging
If you want to debug the application through xdebug, you should change the remote_host parameter in `docker-composer.yml`:
```
    environment:
      - PHP_IDE_CONFIG=serverName=neighborhood-api-php
      - XDEBUG_CONFIG=remote_host=<your_own_ip> remote_port=9030
```
In your PHPStorm, your PHPDebug configuration must filter by IDE key `PHPSTORM` and the server `neighborhood-api-php`

## Errors

### When I start the containers, I see the message 'max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]' from elk container

*PROBLEM*

docker virtual machines have no enough memory to start elasticsearch.

*SOLUTION*
```
sudo vim /etc/sysctl.conf

# Add at end of file
vm.max_map_count=262144

sudo sysctl -w vm.max_map_count=262144
```

### Queues workers doesn't consume messages from queues

*PROBLEM*

You may have more than one queue consumer process running.

*SOLUTION*
```
# Find the process pid that executes consumers
# Command looks like 'php bin/console rabbitmq:multiple-consumer -m 25 domain_events'
ps aux

# Kill all consumer processes
kill [PID]
```
