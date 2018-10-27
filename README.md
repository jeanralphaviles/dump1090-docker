# Dump1090 Flightaware Docker image

Run [dump1090-fa](https://github.com/flightaware/dump1090) (Flightaware fork)
quickly and easily with Docker! No need to worry about installing drivers or
packages.

[Docker Hub](https://hub.docker.com/r/jraviles/dump1090)

## Usage

### Run

Dump1090 needs access to the USB bus to be able to read data from a receiver.

```shell
docker run --rm -d --device /dev/bus/usb --name dump1090 -p 8080:8080 jraviles/dump1090:latest
```

### Building the Docker image locally

```shell
docker build -t jraviles/dump1090:latest .
```

## Skyview

dump1090-docker exposes a webserver on port 8080 serving up Piaware Skyview.
Skyview is a web portal for viewing flights your receiver is picking up on a
map in real time.

![Skyview](https://github.com/jeanralphaviles/dump1090-docker/raw/master/images/skyview.png)

## Reporting live flight data to Flightaware with Piaware

ADS-B data from dump1090-docker can be
[uploaded to Flightaware](https://flightaware.com/adsb) with the help of
[docker-piaware](https://github.com/wnagele/docker-piaware).

First start dump1090-docker and then start docker-piaware.

```shell
docker run --rm -d --link dump1090:beast --name piaware [--env FEEDER_ID=<feeder id>] wnagele/piaware <flightaware user> <flightaware password>
```

Setting a FEEDER\_ID is optional, but it's best to have as Flightaware uses it
to uniquely identify your site. If you don't have a FEEDER\_ID you can find it
on Flightaware's My ADS-B page listed as "Unique Identifier" after running
docker-piaware for the first time.
[Screenshot](https://github.com/jeanralphaviles/dump1090-docker/raw/master/images/feeder_id.png).

Note, if you're running on a Raspberry Pi or a non-x86 machine, the Piaware
image from Docker Hub may not work correctly. If Piaware isn't starting you'll
need to build the image yourself.

```shell
git clone https://github.com/wnagele/docker-piaware.git
cd docker-piaware
docker build -t wnagele/piaware:latest .
```

You can then use the run command from above.

See [docker-piaware](https://github.com/wnagele/docker-piaware) on Github for
more documentation.

## Maintenance

### Uploading new images to Docker Hub

1. Build and push the new image.

   ```shell
   # Make sure you have run docker login
   docker build -t jraviles/dump1090:<arch> .
   docker push jraviles/dump1090:<arch>
   ```

2. Build and push a new manifest with
   [manifest-tool](https://github.com/estesp/manifest-tool).

   ```shell
   # Install manifest-tool
   manifest-tool push from-spec manifest-dump1090.yml
   ```

Supported architectures:

| architecture 	|
|--------------	|
| amd64        	|
| arm64        	|
