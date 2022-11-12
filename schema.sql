DROP TABLE notes;
DROP TABLE entries;

CREATE TABLE entries (
  id serial PRIMARY KEY,
  phrase text UNIQUE NOT NULL,
  response text NOT NULL,
  date_created date NOT NULL DEFAULT current_date
);

CREATE TABLE notes (
  id serial PRIMARY KEY,
  note text NOT NULL,
  entry_id integer NOT NULL,
  FOREIGN KEY (entry_id) REFERENCES entries(id) ON DELETE CASCADE
);

INSERT INTO entries (phrase, response)
VALUES 
('How are you?', 'I''m doing well, and you?'),
('How''s the weather today?', 'I like that its __ outside. How''s your day been?'),
('Test entry353', 'response here'),
('ANother test?', 'yóoo'),
('ANother test???', 'yóosso');

INSERT INTO notes (entry_id, note)
VALUES
(1, 'This is a standard American greeting'),
(1, 'In Europe, people tend to take this phrase more literally'),
(1, 'Usually but not always, Americans do NOT actually want you to tell them about their day.'),
(2, 'testing note2'),
(2, 'testing note2'),
(3, 'testing note3'),
(4, 'testing note4'),
(5, 'testing note5'),
(5, 'testing note5');
