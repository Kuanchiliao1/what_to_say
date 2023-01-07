Ruby version: 3.1.2

Browser and version: Brave v1.45.123

PostgreSQL version: 12.12

Instructions:
- Install the Ruby, Browser, and PSQL to the versions specified above
- Download and extract the zip file
- Install bundler gem
- Run `bundler install` in terminal
*- Create database by using `createdb entries` in terminal
*- Load database dump using `psql -d entries < schema.sql` in terminal
- Run `bundle exec ruby what_to_say.rb` in terminal
*- Login using the "admin" as the user and "password" as the password


Data structures:
- An Entry consists of an id, phrase, response, created on time
- Entry, Phrase, and Response have a 1:1 relationship
- A Note has to have one Entry and is a many:1 relationship
- A Note consists of an id, note, and created on time









