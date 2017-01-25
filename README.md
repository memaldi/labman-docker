[![Build Status](https://travis-ci.org/memaldi/labman-docker.svg?branch=master)](https://travis-ci.org/memaldi/labman-docker)

labman-docker
=============

This repository hosts Dockerfiles and setup files for launching labman_ud (https://github.com/OscarPDR/labman_ud) with Docker. You can follow these steps:

At first, launch an instance of postgresql:

```
docker run --name labman_postgres e POSTGRES_PASSWORD=labmanpassword -e POSTGRES_USER=labman -e POSTGRES_DB=labman_db -d postgres
```

Next, launch an instance of labman_ud:

```
docker run --name labman_web --link labman_postgres:db -v /src/labman_ud/collected_static -d memaldi/labman
```

At last, launch an instance of labman-nginx, an image based on nginx used for serving static files:

```
docker run --link labman_web:web -p 80:80 --volumes-from labman_web -d memaldi/labman-nginx
```

It could take a while at starting because it has to initialize de database, collect the static files, etc.

Using docker-compose
--------------------

You can also use provided docker-compose.yml file:

```yaml
version: '2'

services:
  db:
    image: postgres
    environment:
      - POSTGRES_PASSWORD=labmanpassword
      - POSTGRES_USER=labman
      - POSTGRES_DB=labman_db
  web:
    image: memaldi/labman
    command: bash -c "while ! nc -w 1 -z db 5432; do sleep 0.1; done; ./entrypoint.sh"
    environment:
      - DB_ENV_POSTGRES_PASSWORD=labmanpassword
      - DB_ENV_POSTGRES_USER=labman
      - DB_ENV_POSTGRES_DB=labman_db
    volumes:
      - /tmp/collected_static:/src/labman_ud/collected_static
    depends_on:
      - db
  nginx:
    image: memaldi/labman-nginx
    ports: 
      - "80:80"
    volumes_from:
      - web
    depends_on:
      - web
```

And execute `docker-compose up`