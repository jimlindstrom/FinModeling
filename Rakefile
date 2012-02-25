task :test do
  sh "rspec -c -fd -I. -Ispecs specs/*spec.rb"
end

task :test_no_midi do
  sh "rspec -t ~midi_tests -c -fd -I. -Ispecs specs/*spec.rb"
end
