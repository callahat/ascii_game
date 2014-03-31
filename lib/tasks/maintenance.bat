cd Z:\InstantRails2\rails_apps\ascii_game
echo "If you see this, something went wrong." > lib\tasks\maintenance.log
PATH Z:\InstantRails2\ruby\bin;Z:\InstantRails2\mysql\bin;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;Z:\InstantRails2\Apache;Z:\InstantRails2\PHP
bundle exec rake maintenance:full_maintenance RAILS_ENV=beta --trace > lib\tasks\maintenance.log
