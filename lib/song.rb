class Song
  attr_accessor :id, :name, :album

  def initialize(name, album, id = nil)
    @name = name
    @album = album
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.album)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
    self
  end

  def self.create(name:, album:)
    song = self.new(name, album)
    song.save
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM songs
    SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM songs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
end
