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

INSERT INTO notes (entry_id, note)
VALUES
(1, 'This is a standard American greeting'),
(1, 'In Europe, people tend to take this phrase more literally'),
(1, 'Usually but not always, Americans do NOT actually want you to tell them about their day.'),
(2, 'Basic exchange of names'),
(2, 'Convey enthusiasm with the hi back'),
(3, 'testing note3'),
(4, 'testing note4'),
(5, 'testing note5'),
(5, 'testing note5'),
(6, 'DO NOT give people you don''t know your phone number!');
