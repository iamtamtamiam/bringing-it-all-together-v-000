class Dog
  attr_accessor :name, :breed, :id
  
  def initialize( id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end 
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT, 
      breed TEXT
      )
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end 
  
  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?,?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
    self
  end 
  
  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog 
  end 
  
  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    
    DB[:conn].execute(sql, id).map do |row|
      self.new(id: row[0], name: row[1], breed: row[2])
    end.first 
  end 
  
  def self.find_or_create_by(name, breed)
    dog_search = DB[:conn].execute("SELECT FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog_search.empty?
      dog_data = dog_search[0]
      dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end 
  end 
  
end 