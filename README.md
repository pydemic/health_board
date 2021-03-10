# HealthBoard

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

## Preparing the data

Get with one of the developers the data required to use the system. Extract the directory at `.misc/data`.

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
