docker container stop tegat
docker container prune -f
docker run -d \
 --restart unless-stopped \
 --privileged \
 -v /:/host \
 --net=host --pid=host --ipc=host \
 --name tegat \
 --env-file ../.env \
 tegat-runner:latest


