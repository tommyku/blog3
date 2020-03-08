FROM ruby:2.5-alpine
MAINTAINER tommyku

RUN apk add --update --no-cache build-base nodejs rsync openjdk8-jre \
  && rm -rf /var/cache/apk/*

RUN gem install bundler

WORKDIR "/app"

COPY Gemfile /app/

RUN bundle config

RUN bundle install

EXPOSE 3000

COPY . /app

CMD "./bin/serve"
