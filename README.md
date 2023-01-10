*[Live site]*(https://what-to-say.herokuapp.com/)

# What to Say 💭
Welcome to your personalized language learning phrasebook! With this tool, you can easily record and keep track of your responses to common phrases. Simply click on "Add Entry" to add a phrase and response pair, and use "Edit/View" to review and edit your notes. You can add as many notes as you'd like to each entry, making this an ideal resource for improving your language skills. Start building your phrasebook today and take your language learning to the next level!

## Technical features and challenges:
- CRUD capabilities using PSQL
- Database features extracted into datapersistance.rb
- Implement pagination without dependency
- Inputs are escaped to prevent injection attacks
- Login authentication without dependency
- Flash messaging using session storage
- URL parameters validated

## Versions
Ruby: 3.1.2
Browser: Brave v1.45.123
PostgreSQL: 12.12

## Instructions:
- Install the Ruby, Browser, and PSQL to the versions specified above
- Download and extract the zip file
- Install bundler gem
- Run `bundler install`
- Create database by using `createdb entries`
- Load database dump using `psql -d entries < schema.sql`
- Run with `bundle exec ruby what_to_say.rb`
- Login using the "admin" as the user and "password" as the password

## Conceptual schema:
- An Entry consists of an id, phrase, response, created on time
- Entry, Phrase, and Response have a 1:1 relationship
- The Entries table has the primary key linked to the foreign key of the Notes table and the `ON DELETE` clause is set to `CASCADE`
- A Note has to have one Entry and is a many:1 relationship
- A Note consists of an id, note, and created on time








