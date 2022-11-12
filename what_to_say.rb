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

# Sets the session to the correct state (put in the stripped input!)
# input_type = "Phrase" || "Response"
def add_flash_message_to_session(input, input_type, input_action="entered")
  binding.pry
  if !(1..100).cover? input.size
    session[:failure] << "#{input_type} must be between 1-100 characters."
  elsif @storage.all_entries.any? { |e| e[:phrase] == input} && input_type == "Phrase"
    session[:failure] << "#{input_type} must be unique."
  else
    session[:success] = "The #{input_type} was #{input_action} successfully."
  end

  session.delete(:success) unless session[:failure].empty?
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

helpers do
  # Count number of notes in an entry
  def count_notes(entry_id)
    @storage.all_notes(entry_id).count
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
    ###
  end
end

# Sign in page
get "/users/signin" do
  if session[:username]
    redirect '/'
  end
  
  erb :signin
end

# This splits input array into nested arrays for pagination
def split_array(entries_array)
  entries_array.each_slice(5).to_a
end

get '/' do
  redirect_if_logged_out
  redirect "/entries_page/0"
end

# View all entries in a page
get '/entries_page/:id' do |id|
  redirect_if_logged_out

  @nested_array = split_array(@storage.all_entries)
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
  # @phrase = @storage.all_entries[id.to_i][:phrase]
  entry_id = id.to_i

  @phrase = @storage.phrase(entry_id)
  # Note: @response is reserved and doesn't work
  @entry_response = @storage.response(entry_id)
  erb :edit_entry
end

# View a specific entry
get '/entries/:id' do |id|
  redirect_if_logged_out
  id = id.to_i

  @notes = @storage.all_notes(id)
  @phrase = @storage.phrase(id)
  # Note: @response is reserved and doesn't work
  @entry_response = @storage.response(id)

  erb :entry
end

# Edit page for note of an entry
get '/entries/:entry_id/notes/:note_id/edit' do |entry_id, note_id|
  redirect_if_logged_out
  @note = @storage.note(entry_id.to_i, note_id.to_i)
  erb :edit_note
end

# Edit note of an entry
post '/entries/:entry_id/notes/:note_id/edit' do |entry_id, note_id|
  redirect_if_logged_out
  @note_id = note_id.to_i
  entry_id = entry_id.to_i

  note = params[:note].strip
  @storage.edit_note(entry_id, @note_id, note)

  add_flash_message_to_session(note, "Note", "edited")
  return erb :edit_note unless session[:failure].empty?

  redirect "/entries/#{entry_id}"
end

# Delete note of an entry
post '/entries/:entry_id/notes/:note_id/destroy' do |entry_id, note_id|
  redirect_if_logged_out

  @storage.delete_note(entry_id.to_i, note_id.to_i)
  session[:success] = "The Note has been deleted!"

  redirect "/entries/#{entry_id}"
end

# Add note to an entry
post '/entries/:id/notes' do |id|
  redirect_if_logged_out
  entry_id = id.to_i
  
  @notes = @storage.all_notes(id.to_i)
  note = params[:note].strip
  
  add_flash_message_to_session(note, "Note")
  return erb :entry unless session[:failure].empty?
  binding.pry
  
  @storage.add_note(entry_id, note)

  redirect "/entries/#{id}"
end

# Edit an entry
post '/entries/:id/edit' do |id|
  redirect_if_logged_out
  entry_id = id.to_i

  phrase = params[:phrase_name]
  response = params[:response_name]

  @storage.update_entry(entry_id, phrase, response)
  
  # @storage.set_phrase(entry_id, params[:phrase_name]) 
  # @storage.set_response(entry_id, params[:response_name])

  redirect "/entries/#{entry_id}"
end

# Adding a complete entry
post "/add_entry" do
  redirect_if_logged_out
  new_phrase = params[:new_phrase].strip
  new_response = params[:new_response].strip

  add_flash_message_to_session(new_phrase, "Phrase")
  add_flash_message_to_session(new_response, "Response")

  return erb :entry unless session[:failure].empty?

  session[:success] = "The Entry has been successfully entered."
  @storage.add_entry(new_phrase, new_response)

  redirect "/entries_page/0"
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