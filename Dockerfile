FROM ruby:2.4.1-alpine
MAINTAINER tommyku

RUN apk add --update --no-cache build-base nodejs rsync openjdk8-jre \
  && rm -rf /var/cache/apk/*

RUN gem install rake bundler

WORKDIR "/app"

COPY Gemfile Gemfile.lock /app/

RUN bundle config

RUN bundle install --system

EXPOSE 3000

COPY . /app

CMD "./bin/serve"
