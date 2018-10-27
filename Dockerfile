FROM debian:latest

RUN apt update && apt install -y \
  gcc \
  git \
  libbladerf-dev \
  librtlsdr-dev \
  make \
  ncurses-dev \
  nginx \
  pkg-config

RUN git clone https://github.com/flightaware/dump1090.git /dump1090
WORKDIR /dump1090
RUN make
RUN install ./dump1090 /usr/local/bin

COPY nginx.conf /nginx.conf
COPY mime.types /mime.types

COPY run.sh /run.sh

EXPOSE 8080 30001 30002 30003 30004 30005 30104

ENTRYPOINT ["/run.sh"]
