#!/bin/sh

n=$1

for ((i=0;i<$n;i++)); do 
  time bundle exec ruby main.rb index name "jojo"
done
