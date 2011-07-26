#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'forever'

Forever.run do
  dir  File.expand_path('..', __FILE__)
  log  File.join(dir, '/tatibot.log')
  pid  File.join(dir, '/tatibot.pid')

  on_error do |e|
    puts "error: #{e.message}"
  end

  on_ready do
    require 'dm-core'
    require 'dm-timestamps'
    require 'dm-validations'
    require 'dm-aggregates'
    require 'dm-migrations'
    require 'jabber/bot'
    require 'google_url_shortener'
    require 'twitter'

    # load config
    config = YAML.load_file(File.join(dir, "/bot_config.yml"))

    # load database
    DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/tatibot.db")

    # load models
    $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
    Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }

    bot = Jabber::Bot.new({
      :name      => 'PublicBot',
      :jabber_id => config['bot']['login'],
      :password  => config['bot']['password'],
      :master    => ['barbabot@appspot.com', "alx.girard@gmail.com"],
      :is_public => true,
      :status    => 'Hello, I am PublicBot.',
      :presence  => :chat,
      :priority  => 10,
      :silent    => true,
      :debug     => true
    })

    bot.add_command(
      :syntax      => 'pads',
      :description => 'lists existing pads',
      :regex       => /^#tetalab <[^>]*> pads$/
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
      :regex        => /^#tetalab <[^>]*> pad .*$/,
      :full_message => true
    ) do |sender, message|
      regexp, name, description = message.match(/#tetalab <.*> pad (.[^\s]*)(.*)/).to_a
      @pad = Pad.create(:name => name, :description => description)
      "New pad: #{@pad.to_s}"
    end # add_command

#    bot.add_command(
#      :syntax       => 'scores',
#      :description  => 'show scores on nick',
#      :regex        => /^#tetalab <[^>]*> scores$/,
#      :full_message => true
#    ) do |sender, message|
#      output = "Scores:"
#      NickScore.all(:score.gt => 0, :order => [:score.desc]).each do |nick|
#        output << "\n\t- #{nick[:nick]}: #{nick[:score]}"
#      end
#      output
#    end # add_command
#
#    bot.add_command(
#      :syntax       => '+nick',
#      :description  => 'increment score on nick',
#      :regex        => /^#tetalab <[^>]*> \+.*$/,
#      :full_message => true
#    ) do |sender, message|
#      regexp, nickname = message.match(/#tetalab <.*> \+(.*)$/).to_a
#      nick = NickScore.first_or_create(:nick => nickname)
#      nick.increment
#      nick.save
#      nil
#    end # add_command
#
#    bot.add_command(
#      :syntax       => '-nick',
#      :description  => 'decrement score on nick',
#      :regex        => /^#tetalab <[^>]*> -.*$/,
#      :full_message => true
#    ) do |sender, message|
#      regexp, nickname = message.match(/#tetalab <.*> -(.*)$/).to_a
#      nick = NickScore.first_or_create(:nick => nickname)
#      nick.decrement
#      nick.save
#      nil
#    end # add_command

    if config['twitter']
      Google::UrlShortener::Base.api_key = config['google_url_shortener']
      Twitter.configure do |twitter_config|
        twitter_config.consumer_key       = config['twitter']['consumer_key'].to_s
        twitter_config.consumer_secret    = config['twitter']['consumer_secret'].to_s
        twitter_config.oauth_token        = config['twitter']['oauth_token'].to_s
        twitter_config.oauth_token_secret = config['twitter']['oauth_token_secret'].to_s
      end

      bot.add_command(
        :syntax       => '#tetalab <user> http://<string>',
        :description  => 'speak on barbabot',
        :regex        => /^#tetalab <[^>]*> !http:\/\/.*$/,
        :full_message => true
      ) do |sender, message|
        regexp, user, text = message.match(/#tetalab <(.*)> !(http:\/\/.*)$/).to_a

        if text &&
           url = URI.extract(text).first

          description = text.gsub(url, "").strip
          url = Google::UrlShortener.shorten!(url.to_s) if url.to_s.size > 18

          status = "#{description} #{url.to_s}"

          puts status.size

          if status.size > 140
            output = "Too long for twitter: #{status.size}"
          elsif description.size == 0
            output = "Description manquante"
          else
            output = "tweet: #{status}"
            Twitter.update(status)
          end
        end
        output
      end
    end

    bot.add_command(
      :syntax       => 'version',
      :description  => 'show bot version',
      :regex        => /^#tetalab <[^>]*> version$/,
      :full_message => true
    ) do |sender, message|
      File.expand_path(File.dirname(__FILE__)).split("/").pop
    end # add_command

    bot.connect
  end

end
