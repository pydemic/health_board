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

## Preparing the system

Use:

```bash
mix setup
```

## Seeding data

The data used for development and production is managed outside of this repo.

Ask for instructions in order to generate a sample of the data or to create your own.

With the data available at `priv/data/`, use:

```bash
mix seed
```

## Start the development server

Use:

```bash
mix start
```
