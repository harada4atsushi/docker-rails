FROM centos:centos6

RUN yum -y update
RUN yum -y install gcc git tar openssl openssl-devel gcc-c++

# rbenvのインストール
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN ./root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH 
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

# rubyのインストール
ENV CONFIGURE_OPTS --disable-install-doc
RUN rbenv install 2.1.1
RUN rbenv global 2.1.1

# rails, bundlerのインストール
RUN echo 'eval "options single-request-reopen  "' >> /etc/resolv.conf 
RUN echo 'eval "install: --no-document"' >> .gemrc
RUN echo 'eval "update: --no-document"' >> .gemrc
RUN bash -l -c 'gem install rails bundler'

# railsに必要なパッケージをインストール
RUN yum -y install sqlite sqlite-devel

# railsアプリケーションをclone
RUN mkdir -p /var/www
WORKDIR /var/www/
RUN bash -l -c 'rails new blank_rails'
WORKDIR /var/www/blank_rails

# railsのセットアップ
RUN sed -i -e "s/# gem 'therubyracer'/gem 'therubyracer'/" Gemfile
RUN bash -l -c "bundle install" 

EXPOSE 3000
#CMD rails s 
CMD bash -l -c "rails s"
