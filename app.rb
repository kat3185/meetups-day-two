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

get '/' do
  title = ["You must log in to view this page"]
  if signed_in?
    title = Meetup.all.sort_by { |meetup| meetup.name }
  end
  erb :index, locals: { title: title }
end

post '/join_meetup' do

  if MeetupAttendee.find_by(user_id: session[:user_id], meetup_id: params["id"]) == nil
    user_attending = MeetupAttendee.new(user_id: session[:user_id], meetup_id: params["id"], owner: false)
    if user_attending.save
      redirect "/#{params[:id]}"
    else
      flash[:notice] = "Oh no you ain't"
    end
  else
    flash[:notice] = "Unless you have cloned yourself, you cannot attend twice."
  end

end

post '/leave_meetup' do

  if MeetupAttendee.find_by(user_id: session[:user_id], meetup_id: params[:id]).destroy
    flash[:notice] = "You have left the group."
    redirect "/#{params[:id]}"
  else
    flash[:notice] = "You can never leave this group!"
    redirect "/#{params[:id]}"
  end
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
  erb :view, locals: { meetup: meetup }
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
