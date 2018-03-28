FROM ruby:2.4.2-slim
MAINTAINER "Envato <envato@envato.com>"

RUN apt-get -qq -y update && apt-get install -y \
      git

RUN mkdir -p unwrappr
ADD . unwrappr

RUN gem install bundler
WORKDIR /unwrappr
RUN bundle install
