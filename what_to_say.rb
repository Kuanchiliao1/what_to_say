

=begin
- Get everything into a sessionpersistance thing
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
  set :erb, escape_html: true
end

# Move the config settings for development into one location
configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

before do
  @storage = SessionPersistance.new(session)
  session[:entries] ||= []
  @entries = session[:entries]
  
  # dummy data to test
  if session[:entries] == []
    session[:entries] << {
      phrase: "How are you?", 
      response: "I'm doing well, and you?", 
      notes: ["One of the most popular greetings in the United States", "People love it!"]}
    
    session[:entries] << {
      phrase: "Hey! What do you think you're doing?", 
      response: "Nothing! Just mindin my own business, and you sir?", 
      notes: ["This is a terrible response!", "Not sure I like this one at all..."]}
    
    session[:entries] << {
      phrase: "test phrase 560", 
      response: "this is a super generic response for testing", 
      notes: []}
    
    session[:entries] << {
      phrase: "more testing phrases", 
      response: "a response to a phrase", 
      notes: []}
    
    session[:entries] << {
      phrase: "more testing phrases", 
      response: "asldkfjasd;klj", 
      notes: []}
    
    session[:entries] << {
      phrase: "i funno anymore...", 
      response: "but you CAN know it!", 
      notes: []}

      session[:entries] << {
        phrase: "How are you?", 
        response: "I'm doing well, and you?", 
        notes: []}
      
      session[:entries] << {
        phrase: "Hey! What do you think you're doing?", 
        response: "Nothing! Just mindin my own business, and you sir?", 
        notes: ["This is a terrible response!", "Not sure I like this one at all..."]}
      
      session[:entries] << {
        phrase: "test phrase 560", 
        response: "this is a super generic response for testing", 
        notes: []}
      
      session[:entries] << {
        phrase: "more testing phrases", 
        response: "a response to a phrase", 
        notes: []}
      
      session[:entries] << {
        phrase: "more testing phrases", 
        response: "asldkfjasd;klj", 
        notes: []}
      
      session[:entries] << {
        phrase: "i funno anymore...", 
        response: "but you CAN know it!", 
        notes: []}
  end
end

# Sets the session to the correct state (put in the stripped input!)
# input_type = "Phrase" || "Response"
def input_session_message(input, input_type)
  session[:failure] ||= []
  
  if !(1..100).cover? input.size
    session[:failure] << "#{input_type} must be between 1-100 characters."
  elsif @entries.any? { |e| e[:phrase] == input} && input_type == "Phrase"
    session[:failure] << "#{input_type} must be unique."
  else
    session[:success] = "The #{input_type} was entered successfully."
  end
end

# Predicate for whether user is signed in
def signed_in?
  session[:username]
end

# Redirect if user is not signed in
def redirect_if_logged_out
  if signed_in?
    "nothing"
  else
    session[:target_path] = @env["REQUEST_PATH"]
    redirect '/users/signin'
  end
end

class SessionPersistance
  def initialize(session)
    @session = session
    @session[:entries] ||= []
  end

  def all_entries
    @session[:entries]
  end
end

helpers do
  # Count number of notes in an entry
  def count_notes(entry_id)
    @storage.all_entries[entry_id][:notes].count
  end

  # This splits input array into nested arrays for pagination
  def split_array(entries_array)
    entries_array.each_slice(5).to_a
  end

  # Count total entries
  def total_entries
    @entries.count
  end

  # Count number of pages
  def page_count
    total_entries % 5 == 0 ? (total_entries / 5) : (total_entries / 5) + 1
  end
end

# Add note to an entry
def add_note(entry_id, note)
  notes = @entries[id.to_i][:notes]
  notes << note
end

# Sign in page
get "/users/signin" do
  if session[:username]
    redirect '/'
  end
  
  erb :signin
end

# User/pass validation
post '/users/signin' do
  @user = params[:username]
  pass = params[:password]

  if @user == "admin" && pass == "password"
    session[:welcome] = "Welcome!"
    session[:username] = @user
    redirect session[:target_path]
  else
    session[:failure] = "Invalid credentials!"
    erb :signin
  end
end

# User sign out
post '/users/signout' do
  session.delete(:username)
  session[:success] = "You are signed out now."
  redirect "/"
end

# I think this is sending us into an infinite loop
get '/' do
  redirect_if_logged_out
  redirect "/entries_page/0"
end

# # View all entries
# get '/entries' do
#   erb :entries
# end

# View all entries in a page
get '/entries_page/:id' do |id|
  redirect_if_logged_out

  @nested_array = split_array(@entries)
  @page_id = params[:id].to_i

  erb :entries_page
end

# Add entry page
get '/entries/add' do
  redirect_if_logged_out
  erb :add_entry
end

# Entry edit page
get '/entries/:id/edit' do |id|
  redirect_if_logged_out
  @phrase = @entries[id.to_i][:phrase]
  @entry_response = @entries[id.to_i][:response]
  erb :edit_entry
end

# View a specific entry
get '/entries/:id' do |id|
  redirect_if_logged_out
  @notes = @entries[id.to_i][:notes]
  @phrase = @entries[id.to_i][:phrase]
  @entry_response = @entries[id.to_i][:response]

  erb :entry
end

# Edit page for note of an entry
get '/entries/:entry_id/notes/:note_id/edit' do |entry_id, note_id|
  redirect_if_logged_out
  @note = @entries[entry_id.to_i][:notes][note_id.to_i]
  erb :edit_note
end

# Edit note of an entry
post '/entries/:entry_id/notes/:note_id/edit' do |entry_id, note_id|
  redirect_if_logged_out
  note = params[:note]
  @entries[entry_id.to_i][:notes][note_id.to_i] = note

  input_session_message(note, "Note")

  redirect "/entries/#{entry_id}"
end

# Delete note of an entry
post '/entries/:entry_id/notes/:note_id/destroy' do |entry_id, note_id|
  redirect_if_logged_out
  @entries[entry_id.to_i][:notes].delete_at(note_id.to_i)
  session[:success] = "The note has been deleted!"

  redirect "/entries/#{entry_id}"
end

# Add note to an entry
post '/entries/:id/notes' do |id|
  redirect_if_logged_out
  notes = @entries[id.to_i][:notes]
  notes << params[:note]

  input_session_message(params[:note], "Note")

  redirect "/entries/#{id}"
end

# Edit an entry
post '/entries/:id/edit' do |id|
  redirect_if_logged_out
  @entries[id.to_i][:phrase] = params[:phrase_name]
  @entries[id.to_i][:response] = params[:response_name]

  redirect "/entries/#{id}"
end

# Adding a complete entry
post "/add_entry" do
  redirect_if_logged_out
  new_phrase = params[:new_phrase].strip
  new_response = params[:new_response].strip

  input_session_message(new_phrase, "Phrase")
  input_session_message(new_response, "Response")

  unless session[:failure].empty?
    return erb :add_entry
  end
  # Idea: 
    # Tell user that phrase was valid, and response was invalid and vice verse
    # If both are correct, then give a valid output instead

  session[:entries] << {
    phrase: new_phrase,
    response: new_response,
    notes: []
  }
  redirect "/entries_page/0"
end

# Delete an entry
post '/entries/:id/destroy' do |id|
  redirect_if_logged_out
  @entries.delete_at(id.to_i)
  session[:success] = "The entry has been successfully deleted"

  redirect '/'
end
