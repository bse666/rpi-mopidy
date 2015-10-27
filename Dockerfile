# RPi-Mopidy
# ----------
# ported to new version and ARM compatibility
# for now without pulseaudio.
# original maintainer: Werner Beroux <werner@beroux.com>

FROM resin/rpi-raspbian:jessie
MAINTAINER Sven Behrend

# Official Mopidy install for Debian/Ubuntu along with some extensions
# (see https://docs.mopidy.com/en/latest/installation/debian/ )
ADD https://apt.mopidy.com/mopidy.gpg /tmp/mopidy.gpg
ADD https://apt.mopidy.com/mopidy.list /etc/apt/sources.list.d/mopidy.list

RUN apt-key add /tmp/mopidy.gpg

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    mopidy \
    mopidy-soundcloud \
    mopidy-spotify \
    gstreamer0.10-alsa \
    python-crypto

# Install more extensions via PIP.
ADD https://bootstrap.pypa.io/get-pip.py /tmp/get-pip.py
RUN python /tmp/get-pip.py
RUN pip install six #-U
RUN pip install \
	Mopidy-TuneIn \
	Mopidy-MusicBox-Webclient \
	Mopidy-Podcast-iTunes \
	Mopidy-Podcast \
	Mopidy-YouTube

# Clean-up to save some space
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Default configuration
ADD mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf
RUN chown mopidy:audio -R /var/lib/mopidy/.config

# pulseaudio config
ADD client.conf /etc/pulse/client.conf
run chown root:root /etc/pulse/client.conf

# Start helper script
ADD entrypoint.sh /entrypoint.sh
RUN chown mopidy:audio /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run as mopidy user
USER mopidy

VOLUME /var/lib/mopidy/local
VOLUME /var/lib/mopidy/media
VOLUME /var/lib/mopidy/playlists

EXPOSE 6600
EXPOSE 6680

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/mopidy"]
