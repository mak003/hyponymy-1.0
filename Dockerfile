FROM ubuntu:18.04
MAINTAINER Ma.K <markma0003@gmail.com>

ENV MECAB_OPTIONS -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/ -b 81920
ENV PATH /ex-hyponymy-1.0/pecco-2015-10-05/src:/root/.rbenv/shims:/root/.rbenv/bin:$PATH

# packages update and installation
RUN apt-get update \
 && apt-get -y install git vim sudo curl make bison subversion autoconf openssl zlib1g-dev libssl1.0-dev libreadline-dev libyaml-dev libreadline6-dev build-essential libncurses5-dev libffi-dev libgdbm5 libgdbm-dev\
 && git clone https://github.com/sstephenson/rbenv.git ~/.rbenv \
 && git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build \
 && ./root/.rbenv/plugins/ruby-build/install.sh \

# rbenv
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> .bashrc
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.bash_profile
RUN bash -l -c 'source $HOME/.bash_profile'

#ENV PATH $HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
RUN  CONFIGURE_OPTS='--disable-install-rodc' /root/.rbenv/bin/rbenv install 1.8.7-p375
RUN rbenv global 1.8.7-p375 \
 && rbenv rehash

# mecab
RUN curl -L -o mecab-0.996.tar.gz 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE' \
 && tar zxf mecab-0.996.tar.gz \
 && cd mecab-0.996 \
 && ./configure --enable-utf8-only --with-charset=utf8 \
 && make \
 && make install \
 && cd

# IPA dic
RUN curl -SL -o mecab-ipadic-2.7.0-20070801.tar.gz 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM' \
 && tar zxf mecab-ipadic-2.7.0-20070801.tar.gz \
 && cd mecab-ipadic-2.7.0-20070801 \
 && ./configure --with-charset=utf8 \
 && ldconfig \
 && make \
 && make install \
 && cd

# NEologd dic
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
 && cd mecab-ipadic-neologd \
 && ./bin/install-mecab-ipadic-neologd -n -a -y \
 && cd

#mecab-ruby
RUN curl -SL -o mecab-ruby-0.996.tar.gz 'https://doc-0s-74-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/j9fej5ppppooc9pavf1ei28vs262pbee/1534910400000/13553212398903315502/*/0B4y35FiV1wh7VUNlczBWVDZJbE0?e=download' \
 && tar zxvf mecab-ruby-0.996.tar.gz \
 && cd mecab-ruby-0.996 \
 && sed -i 's%"ruby/version.h"%<version.h>%g' /mecab-ruby-0.996/MeCab_wrap.cpp \
 && ruby extconf.rb \
 && make \
 && make install

# ex-hyponymy-1.0
RUN curl -SL -o ex-hyponymy-1.0.tar.gz 'https://alaginrc.nict.go.jp/hyponymy/src/ex-hyponymy-1.0.tar.gz' \
 && tar zxf ex-hyponymy-1.0.tar.gz \
 && cd ex-hyponymy-1.0 \

# pecco-2015-10-05
 && curl -SL -o pecco-2015-10-05.tar.gz 'http://www.tkl.iis.u-tokyo.ac.jp/~ynaga/pecco/pecco-2015-10-05.tar.gz' \
 && tar zxf pecco-2015-10-05.tar.gz \
 && cd pecco-2015-10-05 \
 && ./configure \

# darts-clone
 && curl -SL -o darts-clone-0.32g.tar.gz 'https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/darts-clone/darts-clone-0.32g.tar.gz' \
 && tar zxf darts-clone-0.32g.tar.gz \
 && cp darts-clone-0.32g/include/darts.h ./darts-clone.h

# ex-hyponymy-1.0-pecco.patch
WORKDIR /ex-hyponymy-1.0/script
RUN curl -SL -o ex-hyponymy-1.0-pecco.patch 'http://www.tkl.iis.u-tokyo.ac.jp/~ynaga/pecco/ex-hyponymy-1.0-pecco.patch' \
 && patch ex_hyponymy.sh ex-hyponymy-1.0-pecco.patch \
 && cd ../pecco-2015-10-05 \
# && sed -i "s|CC = ccache g++ |g" Makefile \ (For macOS)"
 && make -f Makefile

# Edit source code
WORKDIR /ex-hyponymy-1.0/script/lib
RUN sed -i -e "26s%'MeCab'%'/mecab-ruby-0.996/MeCab'%g" /ex-hyponymy-1.0/script/lib/mecab_part.rb 
RUN sed -i -e "173s%#{char}%\#{char}%g" /ex-hyponymy-1.0/script/lib/del_mark.rb
WORKDIR /ex-hyponymy-1.0/script
RUN sed -i -e '1s%/bin/sh%/bin/bash%g' /ex-hyponymy-1.0/script/ex_hyponymy.sh

RUN ls -l /bin/sh \
 && mv /bin/sh /bin/sh.orig \
 && ln -s /bin/bash /bin/sh

# remove build files
WORKDIR /
RUN rm -rf \
    mecab-0.996.tar.gz \
    mecab-ruby-0.996.tar.gz \
    mecab-ipadic-2.7.0-20070801.tar.gz \
    ex-hyponymy-1.0.tar.gz \
    /ex-hyponymy-1.0/pecco-2015-10-05.tar.gz \
    /ex-hyponymy-1.0/pecco-2015-10-05/darts-clone-0.32g.tar.gz

# test if tools are properly installed or download
RUN which mecab && mecab --version
RUN which rbenv && rbenv --version
RUN which ruby && ruby -v
RUN which pecco && pecco -v
