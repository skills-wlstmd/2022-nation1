FROM alpine

RUN apk add --no-cache curl
RUN apk add --no-cache bind-tools
RUN apk add --no-cache libc6-compat 
RUN adduser --disabled-password match

RUN mkdir /app
WORKDIR /app

COPY ./match /app/match
RUN chmod a+rx /app/match

USER match

CMD ["./match"]