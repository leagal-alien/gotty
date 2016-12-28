#! /bin/bash

# Cloud Foundry 用のスタートアップ (go を使用できるようにする)

cp /home/vcap/.bashrc /home/vcap/app

echo "export PATH=\$PATH:/home/vcap/app/bin/go/bin" >> /home/vcap/app/.bashrc

echo "export VIMRUNTIME=/home/vcap/app/.vim" >> /home/vcap/app/.bashrc

echo "alias vi='vim'" >> /home/vcap/app/.bashrc

# あらかじめ、wk/ に go をダウンロードしておく必要あり

tar -C /home/vcap/app/bin/ -xzf /home/vcap/app/wk/go1.7.4.linux-amd64.tar.gz && \

builtin hash -p /home/vcap/app/bin/vim vim && \

/home/vcap/app/bin/go/bin/go get github.com/robfig/cron && \

# 起動
gotty -w bash

