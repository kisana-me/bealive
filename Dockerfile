FROM ruby:3.2.3
RUN apt-get update && apt-get install -y build-essential imagemagick libvips ffmpeg
COPY ./config/imagemagick/policy.xml /etc/ImageMagick-6/policy.xml
RUN gem i -v 7.1.3 rails