#!/bin/bash
git commit -am %1
echo "Pushing to Unfuddle\n"
git push origin master
echo "Pushing to Heroku \n"
git push heroku master
