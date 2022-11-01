class DatabasePersistance
  def initialize(logger)
    @logger = logger
    @db = PG.connect(dbname: "phrases")
  end

  def query(statement, *params)
    # Not sure about these lines
    @logger.info "statement"
  end
  
end