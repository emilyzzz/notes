#### Docker Compose
* docker-compose --help
* docker-compose config
  * docker-compose config  --services
* docker-compose build
  * docker-compose build --no-cache

#### Running
* docker-compose up -d
  * docker-compose up -d --build
  * docker-compose up -d --no-build
* docker-compose stop
* docker-compose restart
* docker-compose pause
* docker-compose unpause
* docker-compose logs --tail 1 -f  (what is the 1 and -f??)
* docker-compose down
  * down: stop and remove containers, networks, images, and volumes
* docker-compose down --remove-orphans

#### Managing
* docker inspect \<docker_name\>
* docker history -H --no-trunc \<docker_name\>
  * -H: human
* docker volume ls -qf dangling=true
* docker volume ls -qf dangling=true | xargs docker volume rm
  * -f: filter, -q: quiet
* docker images | grep '"'"'<none>'"'"' | awk '"'"'{print $3}'"'"' | xargs docker rmi
  * -a: all, -q: quiet, -f: filter
* docker network ls
* dockviz images --tree
* docker run -it --rm
* ls -lh ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2
* docker ps --format '{{.Names}}'
* docker stats $(docker ps --format '{{.Names}}')
* docker ps
  * docker ps -a
  * docker ps --filter name=\<some name\>
  * docker ps -aq -f status=exited
  * docker ps -aq -f status=exited | xargs docker rm
  * -a: all.  without -a, it's all 'running' dockers.
* docker cp \<local file\> \<container\>:/path/to/file.ext

#### portainer dashboard
* docker run -d --name portainer -v "/var/run/docker.sock:/var/run/docker.sock" -p 9000:9000 portainer/portainer --no-auth
* open http://localhost:9000

#### dockviz -- Visualizing Docker Data
* See https://github.com/justone/dockviz
* dockviz images --tree
* docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz