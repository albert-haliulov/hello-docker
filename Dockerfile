FROM node:8.1.0-alpine

ARG IMAGE_CREATE_DATE
ARG IMAGE_VERSION
ARG IMAGE_SOURCE_REVISION

# Metadata as defined in OCI image spec annotations - https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="Hello Docker." \
      org.opencontainers.image.description="Пример для показа установки контейнеризованного приложения. Приложение выводит приветственное сообщение, имя Pod-а и версию ОС хоста на которой запущено." \
      org.opencontainers.image.created=$IMAGE_CREATE_DATE \
      org.opencontainers.image.version=$IMAGE_VERSION \
      org.opencontainers.image.authors="Альберт Халиулов" \
      org.opencontainers.image.url="https://hub.docker.com/r/ahaliulov/hello-docker" \
      org.opencontainers.image.documentation="https://github.com/albert-haliulov/hello-docker/README.md" \
      org.opencontainers.image.vendor="" \
      org.opencontainers.image.licenses="" \
      org.opencontainers.image.source="https://github.com/albert-haliulov/hello-docker.git" \
      org.opencontainers.image.revision=$IMAGE_SOURCE_REVISION 

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY app/package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY app/ /usr/src/app

# Display architecture diagram
RUN echo -e "\n\
     ╔══════════════════════════════════════════════════════════════════════════════╗\n\
     ║                    Hello Docker - Architecture Diagram                       ║\n\
     ╠══════════════════════════════════════════════════════════════════════════════╣\n\
     ║                                                                              ║\n\
     ║  ┌─────────────────┐                                                         ║\n\
     ║  │   HAProxy       │                                                         ║\n\
     ║  │   (Port 80)     │                                                         ║\n\
     ║  └────────┬────────┘                                                         ║\n\
     ║           │                                                                  ║\n\
     ║      ┌────┴───┬─────────┐                                                    ║\n\
     ║      │        │         │                                                    ║\n\
     ║  ┌───▼────┐ ┌─▼─────┐  ┌─▼─────┐                                             ║\n\
     ║  │ hello1 │ │ hello2 │ │hello3 │                                             ║\n\
     ║  │ 8080   │ │ 8080   │ │8080   │                                             ║\n\
     ║  └────────┘ └────────┘ └───────┘                                             ║\n\
     ║                                                                              ║\n\
     ║  3 Node.js backend services with 1 HAProxy load balancer                     ║\n\
     ╚══════════════════════════════════════════════════════════════════════════════╝\n" >&2

EXPOSE 8080

CMD [ "npm", "start" ]
