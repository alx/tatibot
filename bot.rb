require 'rubygems'
require 'bundler/setup'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-aggregates'
require 'dm-migrations'
require 'jabber/bot'

# load models
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }

DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/tatibot.db")

config = YAML.load_file(File.join(File.dirname(__FILE__), "bot_config.yml"))

# Create a new bot
bot = Jabber::Bot.new({
  :name      => 'TatiBot',
  :jabber_id => config['bot']['login'],
  :password  => config['bot']['password'],
  :master    => config['bot']['master'],
  :is_public => true,
  :status    => 'Hello, I am your tatibot.',
  :presence  => :chat,
  :priority  => 10,
  :silent    => true,
  :debug     => true
})

bot.add_command(
  :syntax      => 'pads',
  :description => 'lists existing pads',
  :regex       => /^pads$/
) do |sender, message|
  output = "List of pads:\n"
  Pad.all(:order => [ :created_at.desc ]).each do |pad|
    output << "\t- " << pad.to_s << "\n"
  end
  output
end

bot.add_command(
  :syntax       => 'pad name description',
  :description  => 'create a new pad named and described',
  :regex        => /^pad\s.*$/,
  :full_message => true
) do |sender, message|

  title, description = message.match(/#tetalab <.*> pad (\w*)(.*)/).to_a
  @pad = Pad.new(:title => title, :description => description)

  if @pad.save
    "pad created: #{@pad.to_s}"
  else
    "error saving pad"
  end
end # add_command

bot.connect
