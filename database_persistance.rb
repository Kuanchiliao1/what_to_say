class DatabasePersistance
  def initialize(logger)
    @logger = logger
    @db = PG.connect(dbname: "phrases")
  end
end