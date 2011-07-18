class Pad
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String
  property :description, String
  property :created_at,  DateTime

  validates_presence_of :name

  def to_s
    output = "http://tetalab.org:9000/#{name}"
    if description
      output << " - " << description
    end
    output
  end
end

