# UScore

UScore is a User Scoring API that keeps track of user points over time.

## Requirements

* [Docker]

## Setup

_This setup covers installation using [Docker]. Make sure you have it up and running before continuing._

Clone the repository into your local machine:

```sh
$ git clone git@github.com:davidbrusius/uscore.git
```

Switch to the project directory:

```sh
cd uscore
```

Build docker images:

```sh
docker-compose build
```

Setup UScore database:

```sh
docker-compose run uscore mix ecto.setup
```

All done! You can now run the UScore API!

## Running

Run the UScore API:

```sh
$ docker-compose up -d
```

Watch application logs:

```sh
$ docker-compose logs -f
```

The API will be available at http://localhost:4000

Shutdown the UScore API:

```sh
$ docker-compose down
```

[docker]: (https://www.docker.com/)
