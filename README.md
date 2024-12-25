# Dump1090 Flightaware Docker image

[![Deploy](https://github.com/jeanralphaviles/dump1090-docker/actions/workflows/deploy.yml/badge.svg)](https://github.com/jeanralphaviles/dump1090-docker/actions/workflows/deploy.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/jraviles/dump1090)](https://hub.docker.com/r/jraviles/dump1090/)
[![GitHub](https://img.shields.io/github/license/jeanralphaviles/dump1090-docker.svg)](https://github.com/jeanralphaviles/dump1090-docker)

Run [dump1090-fa](https://github.com/flightaware/dump1090) (Flightaware fork)
quickly and easily with Docker! No need to worry about installing drivers or
packages.

This repository also includes commands to feed ADS-B data to a handful of
flight tracking services, as well as a
[docker-compose](https://docs.docker.com/compose/overview) file to simplify
deployment.

| Supported Flight Tracking Services               |
|------------------------------------------------  |
| [Flightaware](https://flightaware.com/adsb)      |
| [ADS-B Exchange](https://www.adsbexchange.com)   |
| [ADSBHub](http://www.adsbhub.org)                |

Visit dump1090-docker on
[Docker Hub](https://hub.docker.com/r/jraviles/dump1090) :whale: or [Github](https://github.com/jeanralphaviles/dump1090-docker/).

## Usage

### Run

Note, dump1090 needs access to the USB bus to be able to read data from a
receiver.

* Using vanilla Docker

  ```shell
  docker run --rm -d --device /dev/bus/usb --name dump1090 -p 8080:8080 jraviles/dump1090:latest
  ```

* Using docker-compose

  ```shell
  docker-compose up -d dump1090
  ```

### Starting all services at once

```shell
docker-compose up -d
```

To feed data to Flightaware you first must specify your Flightaware username,
password, and optionally your **FEEDER_ID**
[(after claiming it on Flightaware)](https://flightaware.com/adsb/piaware/claim)
in
[flightaware\_credentials.txt](https://github.com/jeanralphaviles/dump1090-docker/blob/master/flightaware_credentials.txt).

### Building the Docker image locally

```shell
docker build -t jraviles/dump1090:latest .
```

## Skyview

dump1090-docker exposes a webserver on port 8080 serving up PiAware Skyview.
Skyview is a web portal for viewing flights your receiver is picking up on a
map in real time.

### Accessing Skyview

Visit <http://localhost:8080>.

![Skyview](https://github.com/jeanralphaviles/dump1090-docker/raw/master/images/skyview.png)

## Feeding live flight data to Flightaware

ADS-B data from dump1090-docker can be
[fed to Flightaware](https://flightaware.com/adsb) with the help of
[docker-piaware](https://github.com/wnagele/docker-piaware).

* Using vanilla Docker

  1. Ensure dump1090 is running.

  1. Run [docker-piaware](https://github.com/wnagele/docker-piaware). To feed
  data to Flightaware you first must specify your Flightaware username,
  password, and optionally your **FEEDER_ID** in
  [flightaware\_credentials.txt](https://github.com/jeanralphaviles/dump1090-docker/blob/master/flightaware_credentials.txt).

     ```shell
     docker run --rm -d --link dump1090:beast --name piaware \
         --env-file flightaware_credentials.txt wnagele/piaware
     ```

     Note, if you're running on a Raspberry Pi or a non-x86 machine, the
     Piaware image from Docker Hub may not work correctly. If Piaware isn't
     starting you'll need to build the image yourself.

     ```shell
     git clone https://github.com/wnagele/docker-piaware.git
     cd docker-piaware
     docker build -t wnagele/piaware:latest .
     ```

     You can then use the run command from above.

* Using docker-compose

  1. Start [docker-piaware](https://github.com/wnagele/docker-piaware) and
     dump1090.

     If using docker-compose, you must specify your Flightaware username,
     password, and optionally your **FEEDER_ID** in
     [flightaware\_credentials.txt](https://github.com/jeanralphaviles/dump1090-docker/blob/master/flightaware_credentials.txt).

     ```shell
     docker-compose up -d piaware dump1090
     ```

Setting a **FEEDER\_ID** is optional, but it's best to have as Flightaware uses
it to uniquely identify your site. If you don't have a **FEEDER\_ID** you can
find it on Flightaware's
[Claim page](https://flightaware.com/adsb/piaware/claim) under "Linked PiAware
Receivers" after running docker-piaware for the first time. There might be
multiple, just pick one.

See [docker-piaware](https://github.com/wnagele/docker-piaware) on Github for
more documentation.

## Feeding live flight data to ADS-B Exchange

ADS-B data from dump1090-docker can be
[fed to ADS-B Exchange](https://www.adsbexchange.com/how-to-feed) with the help
of
[docker-adsbexchange](https://hub.docker.com/search?q=marcelstoer%2Fadsbexchange&type=image)
images.

* Using vanilla Docker

  1. Ensure dump1090 is running.

  1. Run [adsbexchange-feed](https://github.com/marcelstoer/docker-adsbexchange).

     ```shell
     docker run --rm -d -e "INPUT=decoder:30005" --link dump1090:decoder \
         --name adsbexchange-feed marcelstoer/adsbexchange-feed:latest
     ```

  1. Optionally run [adsbexchange-mlat](https://github.com/marcelstoer/docker-adsbexchange).

     Notes:

     1. make sure you replace the dummy values in the command below with your
     effective values
     1. ADS-B Exchange ask you to enter the receiver GPS coordinates for
     [MLAT](https://en.wikipedia.org/wiki/Multilateration) with 5-digit precision
     1. Even though you are giving away the exact receiver position ASD-B
     Exchange will never disclose this information. To protect the privacy of
     the feeders, the receiver locations displayed on their maps (e.g. for
     [Central Europe](https://adsbexchange.com/coverage-4B/)) are approximate
     only.

     ```shell
     docker run --rm -d \
         -e "INPUT=decoder:30005" \
         -e "MLAT_RESULTS=decoder:30104" \
         -e "RECEIVER_LATITUDE=nn.mmmmm" \
         -e "RECEIVER_LONGITUDE=nn.mmmmm" \
         -e "RECEIVER_ALTITUDE=nnnn" \
         -e "RECEIVER_NAME=my-fantastic-ADS-B-receiver" \
         --link dump1090:decoder \
         --name adsbexchange-mlat \
         marcelstoer/adsbexchange-mlat:latest
     ```

* Using docker-compose

  1. Start
     [docker-adsbexchange](https://github.com/marcelstoer/docker-adsbexchange)
     containers and dump1090.

     If using docker-compose, you must specify your MLAT properties in
     [adsbexchange\_mlat\_properties.txt](https://github.com/jeanralphaviles/dump1090-docker/blob/master/adsbexchange_mlat_properties.txt).

     ```shell
     docker-compose up -d dump1090 adsbexchange-feed adsbexchange-mlat
     ```

[docker-adsbexchange](https://github.com/marcelstoer/docker-adsbexchange)
supports
[ADS-B Exchange custom feeds](https://www.adsbexchange.com/how-to-feed/custom-feed-how-to).
To feed data to a custom feed, set the **RECEIVER_PORT** to that of a feed you
have claimed. If unset, adsbexchange-docker will feed the default port: 30005.
To set **RECEIVER_PORT** using docker-compose you must add an
[environment section](https://docs.docker.com/compose/compose-file/#environment)
to adsbexchange-feed's service in
[docker-compose.yml](https://github.com/jeanralphaviles/dump1090-docker/blob/master/docker-compose.yml).

## Feeding live flight data to ADSBHub

ADS-B data can be [fed to ADSBHub](http://www.adsbhub.org/howtofeed.php) with
the help of [adsbhub-docker](https://github.com/jeanralphaviles/adsbhub-docker).

1. [Register for an ADSBHub account](http://www.adsbhub.org/register.php).

1. [Register a new ADS-B station](http://www.adsbhub.org/howtofeed.php).

   Follow instructions on "Adding your ADS-B station to ADSBHub."

1. Run [adsbhub-docker](https://github.com/jeanralphaviles/adsbhub-docker).

* Using vanilla Docker

  1. Ensure dump1090 is running.

  1. Start [adsbhub-docker](https://github.com/jeanralphaviles/adsbhub-docker).

     ```shell
     docker run --rm -d --link dump1090 --name adsbhub jraviles/adsbhub:latest
     ```

* Using docker-compose

  1. Start [adsbhub-docker](https://github.com/jeanralphaviles/adsbhub-docker)
     and dump1090.

     ```shell
     docker-compose up -d adsbhub dump1090
     ```

## Maintenance

### Uploading new images to Docker Hub

1. Ensure that Docker >= 19.03 is installed to support
   [buildx](https://docs.docker.com/buildx/working-with-buildx/).

1. Build and push the new image.

   ```shell
   # Ensure you have run 'docker login'
   export DOCKER_CLI_EXPERIMENTAL=enabled
   docker buildx create --use --name my-builder
   docker buildx build --push --platform linux/amd64,linux/arm64,linux/arm/v7 \
       -t jraviles/dump1090:latest .
   docker buildx rm my-builder
   ```

Supported architectures:

| architecture  |
| ------------  |
| linux/amd64   |
| linux/arm64   |
| linux/armv7   |

## Contributors

* [Jean-Ralph Aviles](https://github.com/jeanralphaviles)
* [Marcel Stör](https://github.com/marcelstoer)
