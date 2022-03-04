1. List all your containers — You need them to check the status of running container, sometimes your peer or orderer may not be running / Exited.
docker ps -a

2. Check logs of containers — You might need them to check logs of peer / orderer when you invoke/query chaincodes , joining peer to channels etc..
docker logs containerid

3. Get into docker container — You may need to go into container to explore volumes which you might mounted during container creation. You can get hold of blocks being routed by orderer or explore the ledger stored in peer.
docker exec -it containerid bash

4.Get into Fabric CLI — If you had defined CLI in docker-compose , then this command can take you to the specified peer.
docker exec -it cli bash

5. Restart Container
docker restart containerid

6. Run all services defined in docker-compose
docker-compose -f yourdockercompose.yaml up -d

7. Run specific service defined in docker-compose
docker-compose -f yourdockercompose.yaml up -d servicename

8. Tear down container volumes
docker-compose -f yourdockercompose.yaml down — volumes

9.Force remove all running containers
docker rm -f $(docker ps -aq)

10. Remove all images which where utilized by containers
docker rmi -f $(docker images -q )

11. Remove images which where utilized by containers with like search
docker rmi -f $(docker images dev-* -q)
