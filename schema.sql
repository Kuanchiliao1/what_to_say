DROP TABLE notes;
DROP TABLE entries;

CREATE TABLE entries (
  id serial PRIMARY KEY,
  phrase text UNIQUE NOT NULL,
  response text NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp
);

CREATE TABLE notes (
  id serial PRIMARY KEY,
  note text NOT NULL,
  entry_id integer NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  FOREIGN KEY (entry_id) REFERENCES entries(id) ON DELETE CASCADE
);

INSERT INTO entries (phrase, response)
VALUES 
('How are you?', 'I''m doing well, and you?'),
('How''s the weather today?', 'I like that its __ outside. How''s your day been?'),
('Hi, my name is __', 'Hi, nice to meet you, my name is George'),
('What do you do?', 'I work as a truck driver for a living.'),
('What do you like to do?', 'I like to __ in my freetime.'),
('What is your phone number?', 'Sorry, I don''t want to give that out right now');

-- INSERT INTO notes (entry_id, note)
-- VALUES
-- (1, 'This is a standard American greeting'),
-- (1, 'In Europe, people tend to take this phrase more literally'),
-- (1, 'Usually but not always, Americans do NOT actually want you to tell them about their day.'),
-- (2, 'Basic exchange of names'),
-- (2, 'Convey enthusiasm with the hi back'),
-- (3, 'testing note3'),
-- (4, 'testing note4'),
-- (5, 'testing note5'),
-- (5, 'testing note5'),
-- (6, 'DO NOT give people you don''t know your phone number!');

INSERT INTO notes (entry_id, note)
VALUES
(1, 'This is a common greeting in the United States.'),
(1, 'In some European countries, people may ask this question more literally and expect a detailed answer.'),
(2, 'Small talk about the weather is common in many cultures.'),
(3, 'Introducing oneself is a basic social interaction.'),
(4, 'Asking about someone''s occupation is a common way to get to know them.'),
(5, 'It''s normal to have hobbies and interests outside of work.'),
(6, 'It''s generally not a good idea to share personal information like phone numbers with strangers.'),
(1, 'This phrase can also be used as a way to start a conversation.'),
(2, 'The weather can have a big impact on people''s mood and plans.'),
(3, 'Exchanging names is an important part of building a relationship.'),
(4, 'Asking about someone''s job can give insight into their skills and interests.'),
(5, 'Having hobbies and activities outside of work can help with stress and well-being.'),
(6, 'It''s important to protect your personal information and be cautious when sharing it with others.'),
(1, 'The way this phrase is used can vary depending on the region and culture.'),
(2, 'Talking about the weather is a common way to break the ice in social situations.'),
(3, 'Introducing yourself is a basic social etiquette.'),
(4, 'Asking about someone''s occupation can help you understand more about their background and career path.');