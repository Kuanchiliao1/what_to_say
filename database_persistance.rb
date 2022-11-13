require "pg"

class DatabasePersistance
  def initialize(logger)
    @logger = logger
    @db = PG.connect(dbname: "entries")
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def all_entries
    sql = "SELECT * FROM entries"
    result = query(sql)

    result.map do |tuple|
      entry_id = tuple["id"]
      note_sql = "SELECT * FROM notes WHERE entry_id = $1"
      result = query(note_sql, entry_id)

      notes = result.map do |note_tuple|
        note_tuple["note"]
      end

      {id: tuple["id"], phrase: tuple["phrase"], response: tuple["response"], notes: notes}
    end
  end

  def entry(entry_id)
    sql = "SELECT * FROM entries WHERE id = $1"
    result = query(sql, entry_id)

    tuple = result.first
    { id: tuple["id"], phrase: tuple["phrase"], response: tuple["response"], notes: [] }
  end

  def add_entry(phrase, response)
    sql = "INSERT INTO entries (phrase, response) VALUES ($1, $2)"
    query(sql, phrase, response)
  end

  def delete_entry(entry_id)
    sql = "DELETE FROM entries WHERE id = $1"
    query(sql, entry_id)
  end

  def edit_entry(entry_id, phrase, response)
    sql = "UPDATE entries SET phrase = $2 WHERE id = $1; "
    query(sql, entry_id, phrase)
    sql = "UPDATE entries SET response = $2 WHERE id = $1;"
    query(sql, entry_id, response)
  end

  def all_notes(entry_id)
    sql = "SELECT * FROM notes WHERE entry_id = $1"
    result = query(sql, entry_id)

    result.map do |tuple|
      {id: tuple["id"], content: tuple["note"], time: tuple["created_at"]}
    end
  end

  def note(entry_id, note_id)
    sql = "SELECT * FROM notes WHERE entry_id = $1 AND id = $2"
    result = query(sql, entry_id, note_id)
    tuple = result.first

    {id: tuple["id"], content: tuple["note"], time: tuple["created_at"]}
  end

  # Add note to an entry
  def add_note(entry_id, note)
    sql = "INSERT INTO notes (entry_id, note) VALUES ($1, $2);"
    query(sql, entry_id, note)
  end

  def edit_note(note_id, note)
    sql = "UPDATE notes SET note = $2 WHERE id = $1;"
    query(sql, note_id, note)
  end

  def delete_note(entry_id, note_id)
     sql = "DELETE FROM notes WHERE entry_id = $1 AND id = $2"
     query(sql, entry_id, note_id)
  end
end