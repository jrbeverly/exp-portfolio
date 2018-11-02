# jrbeverly portfolio

## Summary

Collections data from a specified list of gitlab projects, then converts them into static HTML briefs.

## Getting Started

The project is designed to `git clone` a series of repository, then collect information from each of them. This includes the project icon, name, license, path, etc.

From this information, the project will then for each repository create:

* A brief - A simple static page featuring the README.md of the project rendered in a viewdocs format
* A redirect link, allowing one to navigate to `jrbeverly.me/ref/reponame` to be redirected to the primary git repo

## Acknowledgements

The project icon is retrieved from [the Noun Project](docs/icon/icon.json). The original source material has been altered for the purposes of the project. The icon is used under the terms of the [Public Domain](https://creativecommons.org/publicdomain/zero/1.0/).

The project icon is by [Kiryl Sytsko from the Noun Project](https://thenounproject.com/term/case/134358/).