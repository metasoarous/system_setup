#!/usr/bin/env bash

mkdir -p ~/.vim ~/.vim/tmp ~/.vim/autoload ~/.vim/bundle; \
  curl -Sso ~/.vim/autoload/pathogen.vim \
  https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

cd ~/.vim/bundle

for repo in \
  vim-ruby/vim-ruby \
  mileszs/ack.vim \
  tpope/vim-fugitive \
  tpope/vim-git \
  tpope/vim-surround \
  tpope/vim-vividchalk \
  altercation/vim-colors-solarized \
  ervandew/supertab \
  msanders/snipmate.vim \
  tpope/vim-unimpaired \
  mattn/webapi-vim \
  mattn/gist-vim \
  sjl/tslime.vim \
  vim-scripts/pythoncomplete \
  wgibbs/vim-irblack \
  tpope/vim-endwise \
  tpope/vim-markdown \
  scrooloose/syntastic \
  scrooloose/nerdtree \
  vim-scripts/taglist.vim \
  Rip-Rip/clang_comp \
  kien/ctrlp.vim \
  scrooloose/nerdcommenter \
  garbas/vim-snipmate
do
  git clone git://github.com/$repo.git
done

