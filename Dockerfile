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
RUN make

FROM debian:latest

RUN apt update && \
    apt install -y \
      libbladerf1 \
      libncurses5 \
      librtlsdr0 \
      nginx && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /dump1090/dump1090 /usr/bin/dump1090
COPY --from=builder /dump1090/public_html/ /dump1090/public_html/

COPY nginx.conf /nginx.conf
COPY mime.types /mime.types

COPY run.sh /run.sh

EXPOSE 8080 30001 30002 30003 30004 30005 30104

ENTRYPOINT ["/run.sh"]
