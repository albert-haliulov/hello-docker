docker build -t hello-docker https://github.com/albert-haliulov/2019-cloud-lab-for-sales.git

docker create network net
docker run -d --rm --name hello1 --net-alias hello --network net -p 8081:8080 hello-docker
docker run -d --rm --name hello2 --net-alias hello --network net -p 8082:8080 hello-docker
docker run -d --rm --name hello3 --net-alias hello --network net -p 8083:8080 hello-docker

docker run -d --rm --name balancer1 --network net -v /home/user1/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg -p 80:80 -p 9000:9000 haproxy:2.5.0

while true; do curl -s http://localhost; sleep 1; done


docker compose up
while true; do curl -s http://localhost; sleep 1; done
docker compose down

docker compose up -d
docker network ls
docker ps
docker compose down
