class NickScore
  include DataMapper::Resource

  property :id,          Serial
  property :nick,        String
  property :score,       Integer, :default => 1
  property :created_at,  DateTime

  validates_presence_of :nick

  def increment
    score += 1
  end

  def decrement
    score -= 1
  end
end

