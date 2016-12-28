FROM faisyl/alpine-runit

MAINTAINER jakbutler

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Calibre environment variables
ENV CALIBRE_LIBRARY_DIRECTORY = /opt/calibre/library
ENV CALIBRE_CONFIG_DIRECTORY = /opt/calibre/config

# Auto-import directory
ENV CALIBREDB_IMPORT_DIRECTORY = /opt/calibre/import

# Flag for automatically updating to the latest version on startup
ENV AUTO_UPDATE = 0

# Install packages needed for app
RUN apk update && \
    apk add --no-cache --upgrade \
    bash \
    ca-certificates \
    gcc \
    mesa-gl \
    python \
    qt5-qtbase-x11 \
    imagemagick \
    wget \
    xdg-utils \
    xz && \
#########################################
##          GUI APP INSTALL            ##
#########################################
    wget -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)" && \
    rm -rf /tmp/calibre-installer-cache

# Add the first_run.sh script to run on container startup
ADD first_run.sh /etc/runit_init.d/first_run.sh
RUN chmod +x /etc/runit_init.d/first_run.sh

# Add crontab job to import books in the library
ADD crontab /etc/cron.d/calibre-library-update
RUN chmod 0644 /etc/cron.d/calibre-library-update
RUN touch /var/log/cron.log

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################
VOLUME /opt/calibre/config
VOLUME /opt/calibre/import
VOLUME /opt/calibre/library

# Run container startup script, cron job, and then watch the log file
CMD /bin/sh -c "/sbin/start_runit && /usr/sbin/crond -l 4 && tail -f /var/log/cron.log"



