
FROM docker.n8n.io/n8nio/n8n:latest

ENV GENERIC_TIMEZONE=Asia/Kolkata
ENV TZ=Asia/Kolkata

WORKDIR /home/node

EXPOSE 5678

CMD ["start"]