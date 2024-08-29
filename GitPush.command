#!/bin/bash

cd $(dirname "$BASH_SOURCE")
git add .
git status
git commit -m 'Added SDK iOS 17 and Xcode 15 support'
git push origin master
