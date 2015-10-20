FROM centos:7
MAINTAINER Diego Gutierrez <dgutierrez1287@gmail.com>

RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install ruby gcc ruby-devel supervisor createrepo yum-utils nginx
RUN yum clean all
RUN gem install rb-inotify

RUN mkdir /repo
RUN mkdir /logs

ADD nginx.conf /etc/nginx/nginx.conf
ADD supervisord.conf /etc/supervisord.conf
ADD scan_repo.rb /
ADD startup.sh /

RUN chmod 755 /scan_repo.rb
RUN chmod 755 /startup.sh

EXPOSE 80
VOLUME /repo /logs

ENTRYPOINT ["/startup.sh"]




