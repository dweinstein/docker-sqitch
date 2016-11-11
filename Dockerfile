FROM docteurklein/sqitch:pgsql

WORKDIR /src
ENTRYPOINT ["/opt/run.sh"]

ADD run.sh /opt
