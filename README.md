# It's my website!

[mattbun.io](https://mattbun.io/)

## Getting Started

Clone this repository with submodules

```shell
git clone git@github.com:mattbun/mattbun.github.io.git --recurse-submodules
cd mattbun.github.io
```

This repo uses `nix`! Either...

* Use [`nix-direnv`](https://github.com/nix-community/nix-direnv) and run `direnv allow`
* Open a nix shell with `nix-shell` (or run commands with `nix-shell --command '...'`)
* Manually install the prerequisites found in `shell.nix`

Then to build and start serving the site locally

```shell
make
```

## Creating a post

```shell
make new
```

## Building the site (without serving it)

```shell
make build
```

## Oops I forgot about the submodules when cloning!

```shell
git submodule init
git submodule update
```
