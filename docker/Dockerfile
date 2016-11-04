FROM debian:8.6

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -qy apt-utils aptitude
RUN aptitude install -yq zsh

SHELL ["zsh", "-l", "-c"]

RUN aptitude install -yq build-essential git wget \
      libssl-dev libreadline-dev zlib1g-dev

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zlogin && \
    {~/.rbenv/bin/rbenv init &>> ~/.zlogin || true} && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

RUN rbenv install 2.2.5
RUN rbenv global 2.2.5 && echo 'gem: --no-document' > ~/.gemrc && \
    gem install knife-solo -v 0.6.0 && gem install berkshelf -v 5.1.0

RUN aptitude install -yq gnupg2 gpgv2

# zsh and oh-my-zsh
RUN mkdir -p /opt && cd /opt && git clone https://github.com/robbyrussell/oh-my-zsh.git && \
    cp /opt/oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    \
    sed -i 's/^export ZSH=.*/export ZSH=\/opt\/oh-my-zsh/' ~/.zshrc && \
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="gallois"/' ~/.zshrc && \
    sed -i 's/# DISABLE_AUTO_UPDATE=/DISABLE_AUTO_UPDATE=/' ~/.zshrc

COPY runChef /root
#CMD cd /x && chef-solo -c solo.rb -o debian-backports
CMD /root/runChef && zsh -l
