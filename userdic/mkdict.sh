#!/bin/sh

echo $@
curl -LO https://github.com/phoepsilonix/dict-to-mozc/releases/download/v0.3.0/dict-to-mozc-0.3.0-x86_64-unknown-linux-gnu.tar.gz
tar xf dict-to-mozc-0.3.0-x86_64-unknown-linux-gnu.tar.gz --strip-component=1
curl -LO https://github.com/google/mozc/raw/refs/heads/master/src/data/dictionary_oss/id.def
PATH=$HOME/.cargo/bin:$PATH

USERDIC=user_dic-Neologd
# unidic
SYSTEMDIC1=mecab-unidic-user-dict-seed.20200910.csv
USERDIC1=user_dic-unidic
curl -LO https://github.com/phoepsilonix/mecab-unidic-neologd/raw/refs/heads/master/seed/$SYSTEMDIC1.xz
curl -L -o LICENSE.neologd-unidic https://github.com/phoepsilonix/mecab-unidic-neologd/raw/refs/heads/master/COPYING
xz -d -k $SYSTEMDIC1.xz
./dict-to-mozc -n -U -i ./id.def -f ./$SYSTEMDIC1 > ./$USERDIC1
ls -la $USERDIC1*

# ipadic
SYSTEMDIC2=mecab-user-dict-seed.20200910.csv
USERDIC2=user_dic-ipadic
curl -LO https://github.com/phoepsilonix/mecab-ipadic-neologd/raw/refs/heads/master/seed/$SYSTEMDIC2.xz
curl -L -o LICENSE.neologd-ipadic https://github.com/phoepsilonix/mecab-ipadic-neologd/raw/refs/heads/master/COPYING
xz -d -k $SYSTEMDIC2.xz
./dict-to-mozc -n -P 12 -N 10 -U -i ./id.def -f ./$SYSTEMDIC2 > ./$USERDIC2
ls -la $USERDIC2*

# sudachidict
SYSTEMDIC3=sudachi.csv
USERDIC3=user_dic-SudachiDict
_sudachidict_date=$(curl -s 'http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/' | grep -o '<td>[0-9]*</td>' | grep -o '[0-9]*' | sort -n | tail -n 1)
echo $_sudachidict_date
curl -L -o LICENSE.SudachiDict https://github.com/WorksApplications/SudachiDict/raw/refs/heads/develop/LICENSE-2.0.txt
curl -L -o LEGAL.SudachiDict https://github.com/WorksApplications/SudachiDict/raw/refs/heads/develop/LEGAL
curl -LO "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/${_sudachidict_date}/small_lex.zip"
curl -LO "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/${_sudachidict_date}/core_lex.zip"
curl -LO "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/${_sudachidict_date}/notcore_lex.zip"
unzip -x small_lex.zip
unzip -x core_lex.zip
unzip -x notcore_lex.zip
cat small_lex.csv core_lex.csv notcore_lex.csv > sudachi.csv
rm *_lex.csv
./dict-to-mozc -s -U -i ./id.def -f ./$SYSTEMDIC3 > ./$USERDIC3

cat $USERDIC1 $USERDIC2 > mozc-user_dict.txt
awk 'BEGIN{
    FS="\t"
    OFS="\t"
}
{
    if (!a[$1,$2,$3]++) {
        print $0
    }
}' mozc-user_dict.txt > $USERDIC
ls -la $USERDIC*
split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt $USERDIC $USERDIC-
mkdir -p ../release
[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz
tar cf ../release/${USERDIC}.tar ${USERDIC}-*.txt LICENSE.neologd-unidic LICENSE.neologd-ipadic
xz -9 -e ../release/${USERDIC}.tar

split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt $USERDIC3 $USERDIC3-
mkdir -p ../release
[[ -e ../release/${USERDIC3}.tar.xz ]] && rm ../release/${USERDIC3}.tar.xz
tar cf ../release/${USERDIC3}.tar ${USERDIC3}-*.txt LICENSE.SudachiDict LEGAL.SudachiDict
xz -9 -e ../release/${USERDIC3}.tar

rm $USERDIC $USERDIC-*.txt $USERDIC1 $USERDIC2 $USERDIC3 $SYSTEMDIC1 $SYSTEMDIC2 $SYSTEMDIC3
