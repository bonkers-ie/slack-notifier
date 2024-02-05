FROM ruby:3.3.0

COPY entrypoint.rb /entrypoint.rb
COPY lib /lib
COPY Gemfile /Gemfile
COPY Gemfile.lock /Gemfile.lock

RUN gem install bundler
RUN bundle
RUN chmod +x /entrypoint.rb

ENTRYPOINT ["/entrypoint.rb"]
