FROM ruby:2.6.6

RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  libpq-dev &&\
  curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn

COPY . /spree
WORKDIR /spree

RUN chgrp -R 0 /spree && \
    chmod -R g=u /spree
RUN cd store-frontend && \
      bundle install && \
      yarn install

CMD ["sh", "docker-entrypoint.sh"]
