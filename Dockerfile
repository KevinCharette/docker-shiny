#name of container: docker-shiny
#versison of container: 0.5.1
FROM quantumobject/docker-baseimage
MAINTAINER Angel Rodriguez  "angel@quantumobject.com"

# Set correct environment variables.
ENV HOME /root

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe" >> /etc/apt/sources.list
RUN (echo "deb http://cran.mtu.edu/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9)
RUN apt-get update && apt-get install -y -q r-base  \
                    r-base-dev \
                    gdebi-core \  
                    libapparmor1 \
                    supervisor \
                    sudo \
                    libcurl4-openssl-dev \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*
                    
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')" \
          && update-locale  \
          && wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.2.2.367-amd64.deb \
          && gdebi --n shiny-server-1.2.2.367-amd64.deb \
          && rm shiny-server-1.2.2.367-amd64.deb \
          && mkdir -p /srv/shiny-server \
          && cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/.

##startup scripts  
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't 
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh


##Adding Deamons to containers
#refers to dockerfile_reference

#pre-config scritp for different service that need to be run when container image is create 
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf \
    && /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf

#down/shutdown script ... use to be run in container before stop or shutdown .to keep service..good status..and maybe
#backup or keep data integrity .. 

##scritp that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convitation of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup
VOLUME /var/backups


#add files and script that need to be use for this container
#include conf file relate to service/daemon 
#additionsl tools to be use internally 

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 3838

#creatian of volume 
#VOLUME 

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
