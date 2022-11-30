require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

# This allows use to "store" html blocks access within views via yield keyword
require "sinatra/content_for"
require "pry"
require_relative "database_persistance.rb"

configure do
  enable :sessions
  set :session_secret, '\x12\x9A\x81*U\xCFT\x91\xB7;\xAF\xF2I]\x9C@L\xD5\xB8;\x00\x87\xF3\x82yS(r\x90\xC8\x86\xBB\x13\x92\xA83$O'
  set :erb, escape_html: true
  also_reload "database_persistance.rb" if development?
end

before do
  @storage = DatabasePersistance.new(logger)
  session[:failure] ||= []
end

helpers do
  # Count number of notes in an entry
  def note_count(entry_id)
    @storage.all_notes(entry_id).count
  end

  def note_page_count(count)
    count % 5 == 0 ? (count / 5) : (count / 5) + 1
  end

   # Count number of pages
  def page_count
    total_entries % 5 == 0 ? (total_entries / 5) : (total_entries / 5) + 1
  end

  # Count total entries
  def total_entries
    @storage.all_entries.count
  end

  # Give current page based on the entry id
  def current_page(entry_id)
    total_entries / 5 + 1
  end
end

# Sets the session to the correct state given a stripped input
# input_type = "Phrase" || "Response"
def add_flash_message_to_session(input, input_type, input_action="entered")
  if !(1..100).cover? input.size
    session[:failure] << "#{input_type} must be between 1-100 characters."
  elsif @storage.all_entries.any? { |e| e[:phrase] == input} && input_type == "Phrase"
    session[:failure] << "#{input_type} must be unique."
  else
    session[:success] = "The #{input_type} was #{input_action} successfully."
  end

  session.delete(:success) unless session[:failure].empty?
end

# Redirect if user is not signed in
def redirect_if_logged_out
  if !session[:username]
    session[:target_path] = @env["REQUEST_PATH"]
    redirect '/users/signin'
  end
end

def load_entry(id)
  if @storage.entry(id)
    @storage.entry(id)
  else
    session[:failure] << "The Entry you're looking for was not found."
    redirect "/entries_page/0"
  end
end

def load_note(entry_id, note_id)
  if @storage.note(entry_id, note_id)
    @storage.note(entry_id, note_id)
  else
    session[:failure] << "The Note you're looking for was not found."
    redirect "/entries_page/0"
  end
end

# Splits input array into nested arrays for pagination
def split_array(entries_array)
  entries_array.each_slice(5).to_a
end

# Sign in page
get "/users/signin" do
  if session[:username]
    redirect '/'
  end
  
  erb :signin
end

get '/' do
  redirect_if_logged_out
  redirect "/entries_page/0"
end

# View all entries in a page
get '/entries_page/:id' do |id|
  redirect_if_logged_out

  if page_count <= id.to_i || id.match?(/[\D]/) || id != id.to_i.to_s
    session[:failure] << "Please provide a valid page number (0-#{page_count - 1})."
    redirect '/entries_page/0'
  end

  @nested_array = split_array(@storage.all_entries)
  @page_id = id.to_i

  erb :entries_page
end

# Add Entry page
get '/entries/add' do
  redirect_if_logged_out
  erb :add_entry
end

# Edit Entry page
get '/entries/:id/edit' do |id|
  redirect_if_logged_out
  entry_id = id.to_i

  @phrase = load_entry(entry_id)[:phrase]
  # Note: @response is reserved
  @entry_response = load_entry(entry_id)[:response]
  erb :edit_entry
end

def id_exists(id)
  
end

# View a specific Entry
get '/entries/:id/notes_page/:note_id' do |id, note_id|
  redirect_if_logged_out

  if total_entries <= id.to_i || id.to_s.match?(/[\D]/) || id != id.to_i.to_s
    session[:failure] << "Invalid entry number."
    redirect '/entries_page/0'
  end

  @notes = split_array(@storage.all_notes(id))
  @phrase = load_entry(id)[:phrase]
  
  @entry_response = load_entry(id)[:response]

  erb :entry
end

# Edit page for note of an entry
get '/entries/:entry_id/notes/:note_id/edit' do |entry_id, note_id|
  redirect_if_logged_out

  @note = load_note(entry_id.to_i, note_id.to_i)[:content]
  erb :edit_note
end

# Add note to an entry
post '/entries/:id/notes' do |id|
  redirect_if_logged_out

  entry_id = id.to_i
  @phrase = load_entry(id)[:phrase]
  @entry_response = load_entry(id)[:response]
  
  @notes = @storage.all_notes(id.to_i)
  note = params[:note].strip
  
  add_flash_message_to_session(note, "Note")
  return erb :entry unless session[:failure].empty?
  
  @storage.add_note(entry_id, note)
  redirect "/entries/#{id}/notes_page/0"
end

# Edit note of an entry
post '/entries/:entry_id/notes/:note_id/edit' do |entry_id, note_id|
  redirect_if_logged_out
  @note_id = note_id.to_i
  entry_id = entry_id.to_i
  @note = params[:note].strip

  add_flash_message_to_session(@note, "Note", "edited")
  return erb :edit_note unless session[:failure].empty?
  
  @storage.edit_note(@note_id, @note)
  redirect "/entries/#{entry_id}/notes_page/0"
end

# Delete note of an entry
post '/entries/:entry_id/notes/:note_id/destroy' do |entry_id, note_id|
  redirect_if_logged_out

  @storage.delete_note(entry_id.to_i, note_id.to_i)
  session[:success] = "The Note has been deleted!"

  redirect "/entries/#{entry_id}/notes_page/0"
end

# Adding a complete entry
post "/entries/add" do
  redirect_if_logged_out
  new_phrase = params[:new_phrase].strip
  new_response = params[:new_response].strip

  add_flash_message_to_session(new_phrase, "Phrase")
  add_flash_message_to_session(new_response, "Response")
  return erb :add_entry unless session[:failure].empty?

  session[:success] = "The Entry has been successfully entered."
  @storage.add_entry(new_phrase, new_response)

  redirect "/entries_page/0"
end

# Edit an entry
post '/entries/:id/edit' do |id|
  redirect_if_logged_out
  entry_id = id.to_i
  @phrase = params[:phrase_name].strip
  @entry_response = params[:response_name].strip

  add_flash_message_to_session(@phrase, "Phrase")
  add_flash_message_to_session(@entry_response, "Response")
  return erb :edit_entry unless session[:failure].empty?
  
  session[:success] = "The Entry has been successfully edited"
  @storage.edit_entry(entry_id, @phrase, @entry_response)
  redirect "/entries/#{entry_id}/notes_page/0"
end

# Delete an entry
post '/entries/:id/destroy' do |id|
  redirect_if_logged_out
  @storage.delete_entry(id.to_i)

  session[:success] = "The Entry has been successfully deleted"
  redirect '/'
end

# User/pass validation
post '/users/signin' do
  @user = params[:username]
  pass = params[:password]

  if @user == "admin" && pass == "password"
    session[:success] = "Welcome!"
    session[:username] = @user
    redirect session[:target_path]
  else
    session[:failure] << "Invalid credentials!"
    erb :signin
  end
end

# User sign out
post '/users/signout' do
  session.delete(:username)
  session[:success] = "You are signed out now."
  redirect "/"
end