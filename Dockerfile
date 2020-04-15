FROM ubuntu:18.04
RUN apt-get update && apt-get install -y \
  mysql-client \
  curl \
  s3cmd \
  cron

COPY . /app

COPY ./backup.sh /etc/cron.daily/backup
COPY ./backup-longterm.sh /etc/cron.weekly/backup-longterm
RUN chmod 755 /etc/cron.daily/backup
RUN chmod 755 /etc/cron.weekly/backup-longterm
RUN rm /etc/cron.daily/apt-compat

WORKDIR /app

RUN ./install.sh
RUN mkdir -p /var/backup/db

CMD tail -f /dev/null