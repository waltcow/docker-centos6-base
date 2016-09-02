############################################################
# Dockerfile to build CentOS image for aliyun ecs
# Add Chinese cupport
# Allow ssh login
# Based on CentOS:6
############################################################

FROM centos:centos6
MAINTAINER zfmai <zfmai@coremail.cn>

# Set default root password
ARG ROOT_PASSWORD=123456

RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
COPY Centos-6.repo /etc/yum.repos.d/CentOS-Base.repo
COPY epel-6.repo /etc/yum.repos.d/epel.repo

# Set timezone to UTC+8:00
RUN yum install -y ntpdate && \
   \cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Install SSH service and set default root password to 123456
RUN yum install -y openssh-server openssh-clients && \
sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key && \
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key && \
mkdir /var/run/sshd && \
echo 'root:$ROOT_PASSWORD' | chpasswd

# Add lang support for Chinese
RUN yum -y install kde-l10n-Chinese && \
yum -y reinstall glibc-common && \
localedef --list-archive |egrep -v ^"en_US|zh" |xargs localedef --delete-from-archive && \
mv -f /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && \
build-locale-archive && \
sed -i 's/LANG="en_US.UTF-8"/LANG="zh_CN.UTF-8"/g' /etc/sysconfig/i18n && \
echo 'SUPPORTED="zh_CN.UTF-8:zh_CN:zh:en_US.UTF-8:en_US:en"' >> /etc/sysconfig/i18n

# remove package cache
RUN rm -rf /root/* && \
    rm -rf /var/cache/yum/* && \
    yum clean all 

# export ssh port and start sshd service
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]