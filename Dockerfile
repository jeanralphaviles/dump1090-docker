FROM debian:latest as builder

RUN apt update && \
    apt install -y \
      gcc \
      git \
      libbladerf-dev \
      librtlsdr-dev \
      make \
      ncurses-dev \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flightaware/dump1090.git /dump1090
WORKDIR /dump1090
RUN git checkout 089684e20f4d44f328ca9b8242b2da33afc8662b
RUN make

FROM debian:latest

RUN apt update && \
    apt install -y \
      libbladerf1 \
      libncurses6 \
      librtlsdr0 \
      nginx && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /dump1090/dump1090 /usr/bin/dump1090
COPY --from=builder /dump1090/public_html/ /dump1090/public_html/
# fixes https://github.com/jeanralphaviles/dump1090-docker/issues/2
RUN echo '{"type": "dump1090-docker"}' > /dump1090/public_html/status.json && \
    echo '{"rings": []}' > /dump1090/public_html/upintheair.json

COPY nginx.conf /nginx.conf
COPY mime.types /mime.types

COPY run.sh /run.sh

EXPOSE 8080 30001 30002 30003 30004 30005 30104

ENTRYPOINT ["/run.sh"]
