FROM debian:bookworm-slim

# ENV variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam
ENV CUPSADMIN=admin
ENV CUPSPASSWORD=password


LABEL org.opencontainers.image.source="https://github.com/thijsdelft/cups-docker"
LABEL org.opencontainers.image.description="CUPS Printer Server"
LABEL org.opencontainers.image.author="Anuj Datar <anuj.datar@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/thijsdelft/cups-docker/blob/main/README.md"
LABEL org.opencontainers.image.licenses=MIT


# Install dependencies
RUN apt-get update -qq && apt-get upgrade -qqy \
    && apt-get install -qqy --no-install-recommends \
    apt-utils \
    usbutils \
    tzdata \
    cups \
    cups-filters \
    printer-driver-gutenprint \
    printer-driver-cups-pdf \
    foomatic-db-compressed-ppds \
    openprinting-ppds \
    avahi-daemon \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Fail the build if the Gutenprint filter the Canon MP550 PPD points to is missing
RUN test -x /usr/lib/cups/filter/rastertogutenprint.5.3

EXPOSE 631
EXPOSE 5353/udp

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# back up cups configs in case used does not add their own
RUN cp -rp /etc/cups /etc/cups-bak
VOLUME [ "/etc/cups" ]

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
