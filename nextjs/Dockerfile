FROM node:lts-alpine

ARG SSH_PRIVATE_KEY

RUN apk add --no-cache bash git openssh openssl libressl

RUN npm install -g pnpm

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

RUN echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa

RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN mkdir -p /scripts

COPY manage_repo.sh /scripts/manage_repo.sh
RUN chmod +x /scripts/manage_repo.sh
COPY refresh_nextjs.sh /scripts/refresh_nextjs.sh
RUN chmod +x /scripts/refresh_nextjs.sh

COPY ecosystem.config.js /scripts/ecosystem.config.js

RUN mkdir -p /app

ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

ENV SHELL=/bin/bash

RUN pnpm add -g pm2

COPY github-webhook-server /github-webhook-server
WORKDIR /github-webhook-server
RUN pnpm install --prod

WORKDIR /app

EXPOSE 3000
EXPOSE 5000

CMD ["/bin/sh", "-c", "/scripts/manage_repo.sh && pm2-runtime /scripts/ecosystem.config.js"]