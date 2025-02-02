# Instructions to Build and Push Blueocean Image

> [!Note]
> - Must have docker setup in your system
> - Must also have a Docker Account and a repository set up

- Clone this repo
- Run the following command inside the parent folder
```bash
docker compose build jenkins-blueocean
```
- Verify image has been created
```bash
docker images | grep jenkins-blueocean
```
- Push the image that was generated
```bash
docker push Jeswin8802/jenkins-blueocean
```

> [!Note]
> The name of the image along with the tag must be the same as what was specified in `docker-compose.yml` under `jenkins-blueocean:`

- To stop all containers from running
```bash
docker compose down
```