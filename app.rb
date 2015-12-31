# coding: utf-8

require 'sinatra'
require 'data_mapper'
require 'carrierwave'
require 'carrierwave/datamapper'

enable :sessions

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:./db/base.db')

class ImageUploader < CarrierWave::Uploader::Base
	storage :file

  def extension_white_list
    %w(jpg jpeg gif png)
  end
	def store_dir
		"images/"
	end
end

class Project # Our projects
	include DataMapper::Resource

	property :id,					Serial
	property :title,			String
	property :text,				Text
	property :created_at,	DateTime
	property :updated_at, DateTime
	mount_uploader :image, ImageUploader
end

class Comment # Customer's comments
	include DataMapper::Resource

	property :id, 				Serial
	property :name, 			String
	property :text, 			Text
	property :created_at,	DateTime
	property :updated_at, DateTime
end

class Article # Articles
	include DataMapper::Resource

	property :id, 				Serial
	property :title, 			String
	property :text, 			Text
	property :created_at,	DateTime
	property :updated_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

helpers do
  def protected!
    return if is_authenticated?
	redirect '/'
  end
	def is_authenticated?
	  return !!session[:user]
	end
end

# Main pages

get '/' do
	session[:user] ||= nil
	@projects = Project.all
	@article = Article.first # about a company
	@comments = Comment.all
	erb :index
end

get '/service' do
	session[:user] ||= nil
	@article = Article.last # about a company
	@comments = Comment.all
	erb :service
end


get '/projects' do
	session[:user] ||= nil
	@projects = Project.all
	@comments = Comment.all
	erb :projects
end

get '/contacts' do
	erb :contacts
end

# Authentication
get '/admin' do
	erb :admin
end

post '/login' do
	if params[:login] == "admin" && params[:password] == "123"
		session[:user] = "admin"
		redirect '/'
	else
		redirect '/'
	end
end

get '/logout' do
	session[:user] = nil
	redirect '/'
end

# Project CRUD
get '/project/create' do
	protected!
	erb :project_create
end

post '/project/create' do
	puts params.inspect
  params.delete 'submit'
  params[:updated_at] = params[:created_at] = Time.now
  @project = Project.create(params)
  redirect '/'
end

get '/project/edit/:id' do
	@project = Project.get(params[:id])
	erb :project_edit
end

post '/project/edit/:id' do
	@project = Project.get(params[:id])
	@project.title = params[:title]
	@Project.text = params[:text]
	@Project.image = params[:image] unless params[:image].nil?
	params[:updated_at] = Time.now
	@project.save
	redirect '/'
end

get '/project/delete/:id' do
	Project.get(params[:id]).destroy
  redirect '/'
end

# Comment CRUD
get '/comment/create' do
	protected!
	erb :comment_create
end

post '/comment/create' do
	puts params.inspect
  params.delete 'submit'
  params[:updated_at] = params[:created_at] = Time.now
  @comment = Comment.create(params)
  redirect '/'
end

get '/comment/edit/:id' do
	@comment = Comment.get(params[:id])
	erb :comment_edit
end

post '/comment/edit/:id' do
	@comment = Comment.get(params[:id])
	@comment.name = params[:name]
	@comment.text = params[:text]
	params[:updated_at] = Time.now
	@comment.save
	redirect '/'
end

get '/comment/delete/:id' do
	Comment.get(params[:id]).destroy
  redirect '/'
end

# Article CRUD
get '/article/create' do
	protected!
	erb :article_create
end

post '/article/create' do
	puts params.inspect
  params.delete 'submit'
  params[:updated_at] = params[:created_at] = Time.now
  @article = Article.create(params)
  redirect '/'
end

get '/article/edit/:id' do
	@article = Article.get(params[:id])
	erb :article_edit
end

post '/article/edit/:id' do
	@article = Article.get(params[:id])
	@article.title = params[:title]
	@article.text = params[:text]
	params[:updated_at] = Time.now
	@article.save
	redirect '/'
end

get '/article/delete/:id' do
	Article.get(params[:id]).destroy
  redirect '/'
end