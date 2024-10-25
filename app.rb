# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/multi_route'
require 'sqlite3'

configure do
  db = SQLite3::Database.new(':memory:')
  db.results_as_hash = true
  db.execute('CREATE TABLE IF NOT EXISTS blog (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL);')
  set :db, db
end

helpers do
  def h(text)
    CGI.escape_html(text)
  end
end

def blog_params
  { title: params[:title], content: params[:content] }
end

get '/', '/blogs' do
  @blogs = settings.db.execute('SELECT * FROM blog ORDER BY id DESC')
  erb :index
end

get '/blogs/new' do
  erb :new
end

post '/blogs' do
  settings.db.execute('INSERT INTO blog (title, content) VALUES (:title, :content)', blog_params)
  redirect to('/blogs')
end

get '/blogs/:id/edit' do |id|
  @blog = settings.db.execute('SELECT * FROM blog WHERE id = :id', id:).first
  erb :edit
end

patch '/blogs/:id' do |id|
  settings.db.execute('UPDATE blog SET title = :title, content = :content WHERE id = :id', { **blog_params, id: })
  redirect to('/blogs')
end

delete '/blogs/:id' do |id|
  settings.db.execute('DELETE FROM blog WHERE id = :id', id:)
  redirect to('/blogs')
end

not_found do
  '記事が存在しません'
end
