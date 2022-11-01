class DatabasePersistance
  def initialize(logger)
    @logger = logger
    @db = PG.connect(dbname: "phrases")
  end

  def query(statement, *params)
    # Not sure about these lines
    @logger.info "#{statement}: #{params}"
    db.exec_params(statement, params)
  end

  def all_entries
    sql = "SELECT * FROM entries"
    result = query(sql)

    result.map do |tuple|
      
    end
  end
end