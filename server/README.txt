Server Installation:
-------------------

During development, the server ran Ubuntu 12.04.2 LTS (GNU/Linux 3.5.0-23-generic x86_64).

Prerequisites:
= ruby 1.9.3p484
= rubygems 2.1.11
= nodejs
= Apache2 and Phusion Passenger
= mysql 5.5.35-standard

Setup:
1. Install the bundler gem using 'gem install bundler'
2. Run the 'bundle install' command in the app directory
3. Configure environment variables on the system DB_USER and DB_PASS. These are used in the config/database.yml file.
4. Configure Passenger and Apache.
5. Run the 'rake db:schema:load' command to load the database schema.
