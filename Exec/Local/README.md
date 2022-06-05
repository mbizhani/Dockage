# Local

It is a simple `docker-compose.yml` file useful for local usage. 
You can centralize local services. 

For more information about `docker-compose`, refer to [Docker to the Point - Part 2](https://www.devocative.org/article/tech/docker02)

## Exec Steps
- Copy `docker-compose.yml` file
- `docker network create mynet`
- `docker-compose up -d [SERVICE1 SERVICE2 ...]`
