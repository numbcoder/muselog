
require 'toto'

require 'extends'

# Rack config
use Rack::Static, :urls => ['/css', '/js', '/images', '/favicon.ico'], :root => 'public'
use Rack::CommonLogger

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end

# Syntax Highlighting
require 'coderay'
require 'rack/codehighlighter'
use Rack::Codehighlighter, :coderay, :markdown => true, 
  :theme => "active4d", :lines => true, :element => "pre>code", 
  :pattern => /\A:::(\w+)\s*(\n|&#x000A;)/, :logging => true





#
# Create and configure a toto instance
#
toto = Toto::Server.new do
  #
  # Add your settings here
  # set [:setting], [value]
  # 
  set :author,      "Johnny"                               # blog author
  set :title,     Dir.pwd.split('/').last                   # site title
  set :root,      "index"                                   # page to load on /
  set :date,      lambda {|now| now.strftime("%d/%m/%Y") }  # date format for articles
  set :markdown,  :smart                                    # use markdown + smart-mode
  set :disqus,    "numbcoder"                                     # disqus id, or false
  set :summary,   :max => 250, :delim => /~/                # length of article summary and delimiter
  set :ext,       'txt'                                     # file extension for articles
  set :cache,      28800                                    # cache duration, in seconds

  set :date, lambda {|now| now.strftime("%B #{now.day.ordinal} %Y") }
end

run toto


