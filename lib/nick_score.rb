class NickScore
  include DataMapper::Resource

  property :id,          Serial
  property :nick,        String
  property :score,       Integer, :default => 1
  property :created_at,  DateTime

  validates_presence_of :nick
end

