# coding: utf-8

require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:./db/base.db')

class Post
	include DataMapper::Resource

	property :id,					Serial
	property :title,			String
	property :text,				Text
	property :picture,		String
	property :created_at,	DateTime
	property :updated_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!


get '/admin' do
	erb :admin
end

get '/' do
	@posts = Post.all
	erb :index
end

post '/login' do
	erb :success
end

get '/create' do
	erb :create
end

post '/create' do
  params.delete 'submit'
  params[:updated_at] = params[:created_at] = Time.now
  @post = Post.create(params)
  redirect '/'
end

get '/edit/:id' do
	@post = Post.get(params[:id])
	erb :edit
end

post '/edit/:id' do
	@post = Post.get(params[:id])
	@post.title = params[:title]
	@post.text = params[:text]
	params[:updated_at] = Time.now
	@post.save
	redirect '/'
end


get '/delete/:id' do
	Post.get(params[:id]).destroy
  redirect '/'
end


