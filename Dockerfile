FROM alpine:3.17
ENV LANG us_US
ENV ANSIBLE_VERSION 7.1.0
ENV BUILD_PACKAGES \
	  sudo \
	  bash \
	  git \ 
	  tar \
	  tree \
	  openssh-client \
	  sshpass \
	  libxml2 \
	  libxslt \
	  python3 \
	  py3-pip \
	  tar \
	  ca-certificates
USER root

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.17/main" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v3.17/community" >> /etc/apk/repositories && \
    set -x && \
    \
    echo "==> Upgrading apk and system..."  && \
    apk update && apk upgrade && \
    \
    echo "==> Adding Python runtime..."  && \
    apk add --no-cache ${BUILD_PACKAGES} && \
    pip install --upgrade pip && \
    pip install docker && \
    \
    echo "==> Installing Ansible..."  && \
    pip install ansible==${ANSIBLE_VERSION} && \
    echo "==> Installing build dependencies .." && \
    apk --no-cache add --virtual build-dependencies\
         musl-dev \
         python3-dev \
         libffi-dev \
         openssl-dev  \
         build-base \
         libxml2-dev \
         libxslt-dev \
    && pip3 install --upgrade --ignore-installed pip==22.3.1 pipenv==2022.1.8 && \
    echo "==> Cleaning up..."  && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    echo "==> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible /ansible /home/ansible && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts && \
    echo "==> Add user and group ansible.." && \
    addgroup -S ansible \
    && adduser -S ansible -G ansible -s /bin/sh -H /home/ansible \
    && chown -R ansible:ansible  /ansible \
    && chown -R ansible:ansible  /home/ansible \
    && echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo "==> Installing docker .." && \
    apk add --update --no-cache docker

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library
USER ansible
COPY entrypoint.sh /ansible/entrypoint.sh
WORKDIR /ansible/playbooks

ENTRYPOINT ["/bin/bash", "/ansible/entrypoint.sh"]
