# TERASOLUNA Server Framework for Java (5.x) Development Guideline

This guideline provides best practices to develop highly maintainable Web applications using full stack framework focussing on Spring Framework, Spring MVC, Spring Security and MyBatis, JPA.

This guideline helps to proceed with the software development (mainly coding) smoothly.

> **Note: Stable guidelines**
>
> **GitHub contents is under construction**. Stable guidelines refer to [here](http://terasolunaorg.github.io/guideline/).

[![Build Status](https://travis-ci.org/terasolunaorg/guideline.png?branch=master)](https://travis-ci.org/terasolunaorg/guideline)


## How to contribute

**Contributing (bug report, pull request, any comments etc.) is welcome !!** Please see the [contributing guideline](https://github.com/terasolunaorg/guideline/blob/master/CONTRIBUTING.md) for details.


## Source files

Source files of this guideline are stored into following directories.

* Japanese version : `{repository root}/source/`
* English version  : `{repository root}/source_en/`


## Source file format

This guideline is written by the reStructuredText format(`.rst`).
About the reStructuredText format, refer to the [Sphinx documentation contents](http://sphinx-doc.org/contents.html).


## How to build

We build to HTML and PDF files using the [Sphinx](http://sphinx-doc.org/index.html).
About the Sphinx, refer to the [Sphinx documentation contents](http://sphinx-doc.org/contents.html).

### Install the Sphinx

Please install the Python and Sphinx.

* [Python](https://www.python.org/)
* [Sphinx](http://sphinx-doc.org/index.html)

> **Note: Creating PDF file**
>
> If create a PDF file, LaTeX environment is required.

### Clone a repository

Please clone a `terasolunaorg/guideline` repository or forked your repository.

```
git clone https://github.com/terasolunaorg/guideline.git
```

or

```
git clone https://github.com/{your account}/guideline.git
```

### Build HTML files for the Japanese

Please execute the `build-html.sh` or `build-html.bat`.
If build is successful, HTML files generate to the `{your repository}/build/html/` directory.

Linux or Mac:

```
$ cd {your repository directory}
$ ./build-html.sh
```

Windows:

```
> cd {your repository directory}
> build-html.bat
```

### Build HTML files for the English

Please execute the `build-html_en.sh` or `build-html_en.bat`.
If build is successful, HTML files generate to the `{your repository}/build_en/html/` directory.

Linux or Mac:

```
$ cd {your repository directory}
$ ./build-html_en.sh
```

Windows:

```
> cd {your repository directory}
> build-html_en.bat
```

### Build a PDF file for the Japanese

Please execute the `build-pdf.sh`.
If build is successful, PDF file(`TERASOLUNAServerFrameworkForJavaDevelopmentGuideline.pdf`) generate to the `{your repository}/build/latex/` directory.

```
$ cd {your repository directory}
$ ./build-pdf.sh
```

### Build a PDF file for the English

Please execute the `build-pdf_en.sh`.
If build is successful, PDF file(`TERASOLUNAServerFrameworkForJavaDevelopmentGuideline.pdf`) generate to the `{your repository}/build_en/latex/` directory.

```
$ cd {your repository directory}
$ ./build-pdf_en.sh
```

## Terms of use

Terms of use refer to [here](https://github.com/terasolunaorg/guideline/blob/master/source_en/Introduction/TermsOfUse.rst).
