#!/usr/bin/env rake
require "bundler/gem_tasks"

desc "run the specs"
task :test do
  sh "if git status | grep 'modified:' | grep annual_report >/dev/null; then echo \"\n\nYou should get rid of ~/.finmodeling\"; fi"
  sh "rspec -c -fd -I. -Ispec spec/*spec.rb"
end

desc "purges anything cached"
task :purge_cache do
  sh "rm -rf ~/.finmodeling"
end

desc "purges anything cached, except the raw XBRL filing downloads."
task :purge_cache_except_filings do
  sh "rm -rf ~/.finmodeling/classifiers/ ~/.finmodeling/companies/ ~/.finmodeling/constructors/ ~/.finmodeling/summaries/"
end
