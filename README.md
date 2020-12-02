# HealthBoard

![Test badge](https://github.com/pydemic/health_board/workflows/Test/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/pydemic/health_board/badge.svg)](https://coveralls.io/github/pydemic/health_board)

## Development using docker

Build the development image:

```bash
docker-compose -f .misc/docker/dev/build.yml build
```

Start the services:

```bash
docker-compose -f .misc/docker/dev/docker-compose.yml up -d
```

Access `health_board` service:

```bash
docker-compose -f .misc/docker/dev/docker-compose.yml exec health_board bash
```

## Preparing the system

Use:

```bash
mix setup
```

## Start the development server

Use:

```bash
mix start
```
