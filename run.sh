#!/usr/bin/env bash

db="arc"

[[ -f "$db/is_staging" ]] && git pull

# if in test environment where node isn't 0.10, use nvm to switch to 0.10
[[ $(node --version) != v0.10* ]] && { . ~/.bashrc; nvm use 0.10; }

# if no db, create an empty db
[ -d "$db" ] || {
	echo "creating empty db"
	mkdir "$db"
	echo "admin" > "$db/admins"
	# hacky but works as long as you don't care about opening a repl
	echo '(load "forum.arc") (create-acct "admin" "password") (quit)' | mzscheme -f as.scm
}

[ -d fb-sdk/node_modules ] || { cd fb-sdk; npm install; cd ..; }

read -r -d '' t <<EOF
(require mzscheme) #| promise we won't redefine mzscheme bindings |#
(require "ac.scm")
(require "brackets.scm")
(void (begin #| don't print these |#
(use-bracket-readtable)
(aload "arc.arc")
(aload "libs.arc")
#| load and serve the forum, then open the arc repl |#
(arc-eval '(do (load "forum.arc") (thread (nsv ${1:-8080}))))
(tl)
))
EOF
mzscheme -e "$t"