FROM ruby:2.3.1-alpine
MAINTAINER tommyku

RUN apk add --no-cache build-base nodejs openjdk8 rsync

RUN gem install bundler

COPY Gemfile Gemfile.lock package.json nanoc.yaml Guardfile bin/ /app/

WORKDIR "/app"

RUN bundle install

RUN npm install

EXPOSE 3000

COPY . /app

CMD "./bin/serve"
