DATE=`LC_TIME="en_EN.utf8" date +'%B %d, %Y'`
sed -i -e "s/\\\\date{.*}/\\\\date{${DATE}}/g" ${1}
sed -i -e "s/\\\\renewcommand{\\\\releasename}{リリース}/\\\\renewcommand{\\\\releasename}{Release}/g" ${1}
sed -i -e "s/\\\\begin{notice}{note}{ノート:}/\\\\begin{notice}{note}{Note:}/g" ${1}
sed -i -e "s/\\\\begin{notice}{warning}{警告:}/\\\\begin{notice}{warning}{Warning:}/g" ${1}
sed -i -e "s/\\\\begin{notice}{tip}{ちなみに:}/\\\\begin{notice}{tip}{Tip:}/g" ${1}
sed -i -e "s/\\\\begin{notice}{note}{課題}/\\\\begin{notice}{note}{Todo}/g" ${1}
