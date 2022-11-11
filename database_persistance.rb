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
      note_sql = "SELECT * FROM notes"
      result = query(note_sql)

      notes = (result.map do |note_tuple|
        note_tuple["note"]
      end)

      {id: tuple["id"], phrase: tuple["phrase"], response: tuple["response"], notes: notes}
    end
  end

  def entry(entry_id)
    sql = "SELECT * FROM entries WHERE id = $1"
    result = query(sql, entry_id)
    tuple = result.first

    { id: tuple["id"], phrase: tuple["phrase"], response: tuple["response"], notes: [] }
    # @storage.all_entries[entry_id]
  end

  def add_entry(phrase, response)
    # all_entries << {
    #   phrase: phrase,
    #   response: response,
    #   notes: []
    # }
  end

  def delete_entry(entry_id)
    # all_entries.delete_at(entry_id)
  end

  def all_notes(entry_id)
    all_entries[entry_id][:notes]
  end

  def note(entry_id, note_id)
    # all_notes(entry_id)[note_id]
  end

  # Add note to an entry
  def add_note(entry_id, note)
    # all_notes(entry_id) << note
  end

  def edit_note(entry_id, note_id, note)
    # all_entries[entry_id][:notes][note_id] = note
  end

  def delete_note(entry_id, note_id)
    # all_entries[entry_id][:notes].delete_at(note_id)
  end

  def phrase(entry_id)
    # all_entries[entry_id][:phrase]
  end

  def response(entry_id)
    # all_entries[entry_id][:response]
  end

  def set_phrase(entry_id, phrase)
    # all_entries[entry_id][:phrase] = phrase
  end

  def set_response(entry_id, response)
    # all_entries[entry_id][:response] = response
  end
end
