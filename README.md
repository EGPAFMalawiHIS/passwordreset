# README

cd passwordreset

default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: root
  password: your_mysql_password
  host: localhost

bundle install

RAILS_ENV=development bundle exec rails tailwindcss:build
sudo systemctl restart nginx
sudo systemctl restart puma

./bin/rails tailwindcss:install

rails db:create db:migrate db:seed

rails db:seed

rails server


