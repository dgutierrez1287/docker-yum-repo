FROM centos:7
MAINTAINER Diego Gutierrez <dgutierrez1287@gmail.com>

RUN yum -y install epel-release && yum clean all
RUN yum -y update && yum clean all
RUN yum -y install ruby gcc ruby-devel supervisor createrepo yum-utils nginx && yum clean all
RUN gem install rb-inotify

RUN mkdir /root/repo
RUN mkdir /root/logs

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY scan_repo.rb /root/scan_repo.rb

RUN chmod 700 /root/scan_repo.rb

EXPOSE 80
VOLUME /root/repo /root/logs

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod 700 entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]




