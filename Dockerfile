# using phusion/baseimage as base image
FROM phusion/baseimage:master

COPY files/requirements-apt-get.txt requirements-apt-get.txt

COPY files/passwords.txt passwords.txt

RUN apt-get update && xargs apt-get install -y < requirements-apt-get.txt
RUN rm -rf requirements-apt-get.txt

# create credential
RUN echo root:root | /usr/sbin/chpasswd

# config MODULES
RUN sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config 
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config

# run ssh-keygen non-interactive
RUN ssh-keygen -k -f id_rsa -t rsa -N '' -f /root/.ssh/id_rsa >/dev/null && service ssh restart

RUN curl -so wazuh-agent-4.3.8.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.3.8-1_amd64.deb && WAZUH_MANAGER='172.28.80.1' WAZUH_AGENT_GROUP='default' dpkg -i ./wazuh-agent-4.3.8.deb

RUN update-rc.d wazuh-agent defaults 95 10 && service wazuh-agent start