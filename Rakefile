#!/usr/bin/env rake
require "bundler/gem_tasks"

task :test do
  sh "if git status | grep 'modified:' | grep annual_report >/dev/null; then echo \"\n\nYou should get rid of ~/.finmodeling\"; fi"
  sh "rspec -c -fd -I. -Ispec spec/*spec.rb"
end
