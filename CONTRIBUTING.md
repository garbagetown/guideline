# How to contribute the Development Guideline

This document describes how to contribute the Development Guideline updates.

The Development Guideline is written by the reStructuredText format(`.rst`).
We build to the HTML and PDF files using the [Sphinx](http://sphinx-doc.org/index.html).
About Sphinx and reStructuredText format, refer to the [Sphinx documentation content](http://sphinx-doc.org/contents.html).

Contribution procedures are follows:


## Create a new issue

Please create a new issue from [here](https://github.com/terasolunaorg/guideline/issues/new) for contributing(bug report, improvement or new content), and get an issue number(tracking id).

> **Note: Supported language**
>
> English or Japanese.

* Please write the contribution overview into the title area.
* Please write the contribution detail into the comment area.


## Fork a repository

Please fork the `terasolunaorg/guideline` into your account repository of GitHub.

* Click a "Fork" button on GitHub web user interface.


## Clone a repository

Please clone a forked repository into your local machine.


e.g.)

```
git clone https://github.com/{your account}/guideline.git
```


## Create a work branch

Please create a work branch on the master branch into your local repository.

> **Note: Recommended work branch name**
>
> issues/{issue number}_{shot description}

e.g.)

```
git checkout master
git checkout -b issues/999_typo-in-REST
```


## Modify the Development Guideline

Please modify the development guideline for contributing.

> **Note: Build to the HTML**
>
> If possible, please build to the HTML using the [Sphinx](http://sphinx-doc.org/index.html) and check your modification on the web browser. (Optional)



## Commit a modification

Please commit a modification.

> **Note: Commit comment format**
>
> "#{commit number}: {modification overview}"

> **Note: Supported language**
>
> English only.

e.g.)

```
git commit -a -m "#999: Fixes typos in REST.rst"
```


## Push a work branch

Please push a work branch to the GitHub.

e.g.)

```
git push origin issues/999_typo-in-REST
```


## Create a pull request

Please create a pull request via GitHub web user interface.
For details, please refer to the [GitHub document-Creating a pull request-](https://help.github.com/articles/creating-a-pull-request/).

> **Note: Supported language**
>
> English or Japanese.

* Please write the modification overview into the title area. (Default is commit comment or work branch name)
* Please write the modification detail into the comment area. (If needed)
* Please include the issue number(`#{issue number}` format) to track a modification into the comment area.

e.g.)

```
Title   : #999: Fixes typos in REST.rst
Comment : Please review #999 .
```
