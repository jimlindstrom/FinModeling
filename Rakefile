#!/usr/bin/env rake
require "bundler/gem_tasks"

task :default => "spec:basic"
task :test    => "spec:basic" # to support a legacy task that I've now renamed.

namespace :spec do
  desc "run the specs (just the well-written ones)"
  task :basic do
    sh "if git status | grep 'modified:' | grep annual_report >/dev/null; then echo \"\n\nYou should get rid of ~/.finmodeling\"; fi"
    sh "rspec -c -fd -I. -Ispec --tag ~outdated spec/*spec.rb"
  end
  
  desc "run the specs (including ones that are badly written (depending on certain filings) and need rewritten"
  task :all do
    sh "if git status | grep 'modified:' | grep annual_report >/dev/null; then echo \"\n\nYou should get rid of ~/.finmodeling\"; fi"
    sh "rspec -c -fd -I. -Ispec spec/*spec.rb"
  end
end

desc "purges anything cached"
task :purge_cache do
  sh "rm -rf ~/.finmodeling"
end

desc "purges anything cached, except the raw XBRL filing downloads."
task :purge_cache_except_filings do
  sh "rm -rf ~/.finmodeling/classifiers/ ~/.finmodeling/constructors/ ~/.finmodeling/summaries/"
end
