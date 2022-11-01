

=begin
Basic features:
!- Users can input new words and definitions
  !- This input will be displayed to all
  - User may delete any post
  - User is mainly used to identify oneself as the poster
  - 

- Login authentication for all users
  - Ig store this as a yaml file?
  - Or in database
  *- Look up how to store this in PSQL
  *- Can look at the CFM project for this

- Transition session logic
  - build out the basics
  - change to session persistance
  - change to db persistance
  - look at todoist project for all of this

- Homepage
  - Welcome stuff
  - Set number of posts displayed
    - Pagination
      - Use a method to split things up into multiple equal sized arrays
    - Sort
      - Look at how todolist was sorted

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

      CREATE TABLE entries (
        id serial PRIMARY KEY,
        user_id text REFERENCES users(id) NOT NULL DELETE ON CASCADE,
        created_at timestamp NOT NULL DEFAULT now(),
        comments??,


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
  # set :erb, escape_html: true
end

# Move the config settings for development into one location
configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

before do
  
  session[:entries] ||= []
  
  # dummy data to test
  if session[:entries] == []
    session[:entries] << {
      phrase: "How are you?", 
      context: "", 
      response: "I'm doing well, and you?", 
      comments: []}
    
    session[:entries] << {
      phrase: "Hey! What do you think you're doing?", 
      context: "A security guard is questioning you and you're a burgular", 
      response: "Nothing! Just mindin my own business, and you sir?", 
      comments: ["This is a terrible response!", "Not sure I like this one at all..."]}
    
    session[:entries] << {
      phrase: "test phrase 560", 
      context: "", 
      response: "this is a super generic response for testing", 
      comments: []}
    
    session[:entries] << {
      phrase: "more testing phrases", 
      context: "", 
      response: "a response to a phrase", 
      comments: []}
    
    session[:entries] << {
      phrase: "more testing phrases", 
      context: "", 
      response: "asldkfjasd;klj", 
      comments: []}
    
    session[:entries] << {
      phrase: "i funno anymore...", 
      context: "", 
      response: "but you CAN know it!", 
      comments: []}

      session[:entries] << {
        phrase: "How are you?", 
        context: "", 
        response: "I'm doing well, and you?", 
        comments: []}
      
      session[:entries] << {
        phrase: "Hey! What do you think you're doing?", 
        context: "A security guard is questioning you and you're a burgular", 
        response: "Nothing! Just mindin my own business, and you sir?", 
        comments: ["This is a terrible response!", "Not sure I like this one at all..."]}
      
      session[:entries] << {
        phrase: "test phrase 560", 
        context: "", 
        response: "this is a super generic response for testing", 
        comments: []}
      
      session[:entries] << {
        phrase: "more testing phrases", 
        context: "", 
        response: "a response to a phrase", 
        comments: []}
      
      session[:entries] << {
        phrase: "more testing phrases", 
        context: "", 
        response: "asldkfjasd;klj", 
        comments: []}
      
      session[:entries] << {
        phrase: "i funno anymore...", 
        context: "", 
        response: "but you CAN know it!", 
        comments: []}
  end

  @entries = session[:entries]

  # For database addition
  # @storage = DatabasePersistance.new(logger)
end

# Input validation
def valid?(input)
  # Take out the spaces in the back and in the front
  input = input.strip

  # If input is not equal to empty string, then return true
  input != ""
end

helpers do
  # List out all the submitted entries
  # Note: remember to use pagination
  # Do not display comments here
  def display_entries
    @entries.map do |entry|
      phrase = entry[:phrase]
      response = entry[:response]
      comments = entry[:comment]

      <<~TEXT
        <p>Phrase: #{phrase}</p>
        <p>Response: <strong>#{response}</strong></p>
        <p>Comments: <strong>#{comments}</strong></p><br>
      TEXT
    end.join("\n\n")
  end

  # Refactor this later
  def display_search(query)
    # If redirected to "/" route, query would be nil
    # This will set it to an empty string instead
    query ||= ""
    
    filtered = @entries.filter_map do |phrase_hash|
      phrase = phrase_hash[:phrase]
      context = phrase_hash[:context]
      response = phrase_hash[:response]

      next unless phrase.match?(/#{query}/i) || response.match?(/#{query}/i)

      "<ol>" + phrase + 
        # "<li>context: " + context + "</li>" +
        "<li>response: " + response + "</li>" +
      "</ol>" 
    end.join("<br>")
    # Have to refactor that to replace regardless of case
    filtered.gsub(query, "<span style='color: red'>#{query}</span>")
  end
end

# Sign up page
get "/users/signin" do
  binding.pry
  erb :signin
end

# User/pass validation
post '/users/signin' do
  user = params[:username]
  pass = params[:password]

  # If condition here...
    # session[:welcome] = "Welcome!"
    # then redirect "/"
  # else
    # 
end

# Validate input post m

# Validate input phrase m
get '/' do
  @entries = session[:entries]
  erb :homepage, layout: :layout
end

# View all entries
get '/entries' do
  erb :entries
end

# Adding a partial entry

# Adding a complete entry
post "/add_entry" do
  new_phrase = params[:new_phrase]
  new_context = params[:new_context]
  new_response = params[:new_response]

  if !valid?(new_phrase)
    session[:failure] = "ur stuff is invalidated!"
  end

  session[:entries] << {
    phrase: new_phrase,
    response: new_response,
    comments: [],
    votes: 0}
  redirect "/"
end

get "/search" do
  @query = params[:query]
  erb :homepage
end