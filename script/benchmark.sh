# run deep_import profiling
bundle exec rake benchmark $@

# run standard profiling
bundle exec rake benchmark  $@ deep_import_disable_railtie=1

