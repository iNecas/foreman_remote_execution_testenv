# foreman remote execution target container
#
# VERSION               0.0.1

FROM centos:7
MAINTAINER Ivan Nečas <inecas@redhat.com>

RUN yum install -y openssh-server

ADD ssh/id_rsa_server /etc/ssh/ssh_host_rsa_key
ADD ssh/id_rsa_server.pub /etc/ssh/ssh_host_rsa_key.pub

CMD mkdir -m 700 /root/.ssh
ADD ssh/id_rsa_client.pub /root/.ssh/authorized_keys
CMD chmod 600 /root/.ssh/authorized_keys

ADD scripts/register-host.sh register-host.sh
ADD scripts/start.sh start.sh

EXPOSE 22
CMD ["./start.sh"]
