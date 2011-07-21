class NickScore
  include DataMapper::Resource

  property :id,          Serial
  property :nick,        String
  property :score,       Integer, :default => 0
  property :created_at,  DateTime

  validates_presence_of :nick

  def increment
    self.score += 1
  end

  def decrement
    self.score -= 1
  end
end

