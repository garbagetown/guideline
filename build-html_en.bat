cd /D %~dp0
rem rd /S /Q build_en\html

SET SPHINXOPTS=-c conf\html
SET SOURCEDIR=source_en
SET BUILDDIR=build_en

call make.bat html
pause