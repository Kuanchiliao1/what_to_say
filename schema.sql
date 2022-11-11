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
  FOREIGN KEY (entry_id) REFERENCES entries(id) 
);

INSERT INTO entries (phrase, response)
VALUES ('Test entry?', 'response here'),
('ANother test?', 'yóoo'),
('ANother test???', 'yóosso');

INSERT INTO notes (note, entry_id)
VALUES
('testing note1', 1),
('testing note2', 1),
('last testing note', 3);
