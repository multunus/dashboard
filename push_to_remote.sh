#!/bin/bash
git commit -am %1
echo "Pushing to Unfuddle"
git push origin master
echo "Pushing to Heroku "
git push heroku master
