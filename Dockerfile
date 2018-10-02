FROM debian:latest

RUN apt update && apt install -y \
  gcc \
  git \
  libbladerf-dev \
  librtlsdr-dev \
  make \
  ncurses-dev \
  pkg-config

RUN git clone https://github.com/flightaware/dump1090.git /dump1090
WORKDIR /dump1090
RUN make

EXPOSE 30001
EXPOSE 30002
EXPOSE 30003
EXPOSE 30004
EXPOSE 30005
EXPOSE 30104

ENTRYPOINT ["./dump1090"]
CMD ["--net", "--quiet", "--write-json", "/data"]
