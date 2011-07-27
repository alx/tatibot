class Pad
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String
  property :description, String
  property :created_at,  DateTime

  validates_presence_of :name

  def to_s
    #pad_url = "tetalab.org:9000"
    pad_url = "pad.tetalab.org/p"
    output = "http://#{pad_url}/#{name}"
    if description
      output << " - " << description
    end
    output
  end
end

