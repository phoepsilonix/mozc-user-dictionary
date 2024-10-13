#!/bin/sh

echo $@
curl -LO https://github.com/phoepsilonix/dict-to-mozc/releases/download/v0.3.0/dict-to-mozc-0.3.0-x86_64-unknown-linux-gnu.tar.gz
tar xf dict-to-mozc-0.3.0-x86_64-unknown-linux-gnu.tar.gz --strip-component=1
curl -LO https://github.com/google/mozc/raw/refs/heads/master/src/data/dictionary_oss/id.def
PATH=$HOME/.cargo/bin:$PATH

# unidic
SYSTEMDIC=mecab-unidic-user-dict-seed.20200910.csv
USERDIC=user_dic-unidic
curl -LO https://github.com/phoepsilonix/mecab-unidic-neologd/raw/refs/heads/master/seed/$SYSTEMDIC.xz
curl -L -o LICENSE.neologd-unidic https://github.com/phoepsilonix/mecab-unidic-neologd/raw/refs/heads/master/COPYING
xz -d -k $SYSTEMDIC.xz
./dict-to-mozc -n -U -i ./id.def -f ./$SYSTEMDIC > ./$USERDIC
ls -la $USERDIC*
split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt $USERDIC $USERDIC-
mkdir -p ../release
[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz

tar cf ../release/${USERDIC}.tar ${USERDIC}-*.txt LICENSE.neologd-unidic
xz -9 -e ../release/${USERDIC}.tar

rm $USERDIC $USERDIC-*.txt ./$SYSTEMDIC

# ipadic
SYSTEMDIC=mecab-user-dict-seed.20200910.csv
USERDIC=user_dic-ipadic
curl -LO https://github.com/phoepsilonix/mecab-ipadic-neologd/raw/refs/heads/master/seed/$SYSTEMDIC.xz
curl -L -o LICENSE.neologd-ipadic https://github.com/phoepsilonix/mecab-ipadic-neologd/raw/refs/heads/master/COPYING
xz -d -k $SYSTEMDIC.xz
./dict-to-mozc -n -P 12 -N 10 -U -i ./id.def -f ./$SYSTEMDIC > ./$USERDIC
ls -la $USERDIC*
split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt $USERDIC $USERDIC-
mkdir -p ../release
[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz
tar cf ../release/${USERDIC}.tar ${USERDIC}-*.txt LICENSE.neologd-ipadic
xz -9 -e ../release/${USERDIC}.tar

rm $USERDIC $USERDIC-*.txt ./$SYSTEMDIC
