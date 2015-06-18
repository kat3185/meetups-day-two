# pair programmed with Joseph Tessel
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

def user_attending(meetup)
  MeetupAttendee.find_by(user_id: session[:user_id], meetup_id: meetup.id).present?
end

def add_user_to_meetup(meetup_id)
  user_attending = MeetupAttendee.new(user_id: session[:user_id], meetup_id: meetup_id)
  if user_attending.save
    flash[:notice] = "We're glad you're coming!"
  else
    flash[:notice] = "You must sign in to attend a meetup!"
  end
end

get '/' do
  title = Meetup.all.sort_by { |meetup| meetup.name }
  erb :index, locals: { title: title }
end

post '/join_meetup' do
  if MeetupAttendee.find_by(user_id: session[:user_id], meetup_id: params[:id]) == nil
    add_user_to_meetup(params[:id])
  else
    flash[:notice] = "Unless you have cloned yourself, you cannot attend twice."
  end
  redirect "/#{params[:id]}"
end

post '/leave_meetup' do
  if MeetupAttendee.find_by(user_id: session[:user_id], meetup_id: params[:id]).destroy
    flash[:notice] = "You have left the group."
  else
    flash[:notice] = "You can never leave this group!"
  end

  redirect "/#{params[:id]}"
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/:id' do
  meetup = Meetup.find(params[:id])
  session[:meetup_id] = params[:id]
  # meetup_comments = Comment.find_by(meetup_id: params[:id])
  # meetup_comments = meetup_comments.sort_by { |comment| comment.id }
  erb :view, locals: { meetup: meetup}
end

get '/example_protected_page' do
  authenticate!
end

post '/create_meetup' do
  meetup = Meetup.new(params["meetup"])

  if meetup.save
    MeetupAttendee.create(user_id: session[:user_id], meetup_id: meetup.id, owner: true)
    flash[:notice] = "Your meetup has been created!"
    redirect '/'
  else
    flash[:notice] = 'I am unable to create that meetup!'
  end
end

post '/create_comment' do
  comment = Comment.new(body: params[:comment][:body], meetup_id: params[:comment][:meetup_id], user_id: session[:user_id], title: params[:comment][:title])
  if comment.save
    flash[:notice] = "Your comment has been saved!"
  else
    flash[:notice] = "Your comment was NOT saved.  Haha."
  end
  redirect "/#{params[:comment][:meetup_id]}"
end
