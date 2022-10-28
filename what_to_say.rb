

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
  - Displaying the posts/comments that have responses
    - Comments are nested in
- How are comments related to users?
  - Every comment has to have exactly one user
  - Each user may have none or multiple comments
  - This is our one-many relationship plain n simple
      CREATE TABLE users (
        id serial PRIMARY KEY,
        username text NOT NULL,
        created_on date NOT NULL
      )

      CREATE TABLE comments (
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
  session[:posts] ||= []
  
  # dummy data to test
  session[:posts] << {phrase: "test phrase", response: "sample response", comments: []}
  session[:posts] << {phrase: "another test phrase", response: "sample response 2", comments: []}
  session[:posts] << {phrase: "test phrase 560", response: "", comments: []}
  session[:posts] << {phrase: "more testing phrases", response: "", comments: []}

  @posts = session[:posts]
end

helpers do
  # List out all the submitted phrases
  def display_phrases
    
  end

  def display_search(query)
    @posts.map do |phrase_hash|
      binding.pry
      if phrase_hash[:phrase]
        phrase_hash[:phrase].map do |hash|

        end
      end
      "<li>" + phrase_hash[:phrase] + "</li>"
    end.join
  end
end

# Validate input post m

# Validate input phrase m
get '/' do
  @posts = session[:posts]
  erb :homepage, layout: :layout
end

post "/new_post" do
  phrase_name = params[:new_phrase]
  session[:posts] << {phrase: phrase_name, response: "", comments: []}
  redirect "/"
end

post "/search" do
  @query = params[:query]
  redirect "/"
end