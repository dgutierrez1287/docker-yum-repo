FROM centos:7
MAINTAINER Diego Gutierrez <dgutierrez1287@gmail.com>

RUN yum -y install epel-release && yum clean all
RUN yum -y update && yum clean all
RUN yum -y install ruby gcc ruby-devel createrepo yum-utils && yum clean all
RUN gem install rb-inotify

RUN mkdir /root/repo
RUN mkdir /root/logs

COPY scan_repo.rb /root/scan_repo.rb

RUN chmod 755 /root/scan_repo.rb

VOLUME /root/repo /root/logs

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod 755 entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]




