rm -rf build
make SPHINXOPTS="-c conf/latexpdfen" SOURCEDIR=source_en REPLACE_SHELL=conf/latexpdfen/ja2en.sh latexpdfen
