#!/bin/bash

cd $(dirname "$BASH_SOURCE")
git add .
git status
git commit -m 'Added SPM Swift Package Manager support'
git push origin master
