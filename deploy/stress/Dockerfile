FROM alpine

RUN apk add --no-cache curl
RUN apk add --no-cache bind-tools
RUN apk add --no-cache libc6-compat 
RUN adduser --disabled-password stress

RUN mkdir /app
WORKDIR /app

COPY ./stress /app/stress
RUN chmod a+rx /app/stress

USER stress

CMD ["./stress"]