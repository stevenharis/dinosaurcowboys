namespace :db do
  desc 'Pull database contents from pgbackups'
  task pull: [:download, :reset] do
    system 'pg_restore --verbose --clean --no-acl --no-owner -h localhost -U \
            postgres -d party_shark_development latest.dump'
  end

  desc 'Download latest database from pgbackups'
  task :download do
    system 'curl -o latest.dump `heroku pgbackups:url --remote production`'
  end

  desc 'Request pgbackups to capture a backup'
  task :capture do
    system 'heroku pgbackups:capture --remote production'
  end
end
