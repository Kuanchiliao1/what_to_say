

=begin
Basic features:
!- Users can input new words and definitions
  !- This input will be displayed to all
- Login authentication for all users
  - Ig store this as a yaml file?
  - Or in database
  *- Look up how to store this in PSQL
- Homepage
  - Welcome stuff
  - Set number of posts displayed
    - Pagination
  - User chooses to Post a request, respond to a Post, or submit a new entry
    - Use three buttons
      - post requests using forms perhaps
  - Displaying the phrases that have responses
    - Comments are nested in
- How are comments related to users?
  - Every phrase has to have exactly one user
  - Each user may have none or multiple responses
  - This is our one-many relationship plain n simple
      CREATE TABLE users (
        id serial PRIMARY KEY,
        username text NOT NULL,
        created_on date NOT NULL
      )

      CREATE TABLE responses (
        id serial PRIMARY KEY,
        user_id text REFERENCES users(id) NOT NULL DELETE ON CASCADE,
        created_at timestamp NOT NULL DEFAULT now()
      )
- 
- 
=end

require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

# This allows use to "store" html blocks access within views via yield keyword
require "sinatra/content_for"
require "pry"

configure do
  enable :sessions
  set :session_secret, '\x12\x9A\x81*U\xCFT\x91\xB7;\xAF\xF2I]\x9C@L\xD5\xB8;\x00\x87\xF3\x82yS(r\x90\xC8\x86\xBB\x13\x92\xA83$O'
end

before do
  session[:entries] ||= []
  
  # dummy data to test
  if session[:entries] == []
    session[:entries] << {phrase: "How are you?", context: "", response: "I'm doing well, and you?", comments: []}
    session[:entries] << {phrase: "Hey! What do you think you're doing?", context: "A security guard is questioning you and you're a burgular", response: "Nothing! Just mindin my own business, and you sir?", comments: ["This is a terrible response!", "Not sure I like this one at all..."]}
    session[:entries] << {phrase: "test phrase 560", context: "", response: "", comments: []}
    session[:entries] << {phrase: "more testing phrases", context: "", response: "", comments: []}
  end

  @entries = session[:entries]

  # For database addition
  # @storage = DatabasePersistance.new(logger)
end

helpers do
  # List out all the submitted entries
  # Note: remember to use pagination
  # Do not display comments here
  def display_entries
    @entries.map do |entry|
      phrase = entry[:phrase]
      response = entry[:response]

      <<~TEXT
        #{response}
        #{phrase}
      TEXT
    end.join("\n\n")
  end

  # Refactor this later
  def display_search(query)
    # 
    filtered = @entries.filter_map do |phrase_hash|
      phrase = phrase_hash[:phrase]
      response = phrase_hash[:response]

      next unless phrase.match?(/#{query}/i) || response.match?(/#{query}/i)
      "<li>" + phrase + 
        "<br>content: " + response +
      "</li>" 
    end.join("<br>")

    # Have to refactor that to replace regardless of case
    filtered.gsub(query, "<span style='color: red'>#{query}</span>")
  end
end

# Validate input post m

# Validate input phrase m
get '/' do
  @entries = session[:entries]
  erb :homepage, layout: :layout
end

# Adding a partial entry

# Adding a complete entry
post "/add_entry" do
  phrase_name = params[:new_phrase]
  session[:entries] << {phrase: phrase_name, response: "", comments: []}
  redirect "/"
end

get "/search" do
  @query = params[:query]
  erb :homepage
end