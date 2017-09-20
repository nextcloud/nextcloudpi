#!/bin/bash

source buildlib.sh

generate_changelog

git add changelog.md

git commit -C HEAD --amend

git push 

git push --tags
