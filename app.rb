class App < Sinatra::Base

    def db
        return @db if @db
        @db = SQLite3::Database.new('./db/asdas.db')
        @db.results_as_hash = true
        return @db
    end

    get '/' do
        @movies = db.execute('SELECT * FROM movie_db')
        erb :index
    end

    get '/register' do
        erb :register
    end

    post '/register' do
        username = params["username"]
        password = params["password"]

        query = 'INSERT INTO login_credentials (username, password) VALUES (?,?)'
        db.execute(query, username, password)
        redirect "/"
    end

    get '/add_movie' do 
        erb :add_movie
    end
    
    post '/movie/add' do
        title = params["title"]
        description = params["description"]
        year = params["year"]
        movie_image = params["movie_image"]
        genre = params["genre"]
        director = params["director"]

        query = 'INSERT INTO movie_db (title, description, year, movie_image, genre, director) VALUES (?,?,?,?,?,?)'
        db.execute(query, title, description, year, movie_image, genre, director)
        redirect "/"
    end

    post '/movie/remove/:id' do |id| 
        db.execute('DELETE FROM movie_db WHERE id = ?', id)
        redirect "/"
    end

    get '/movie/edit/:id' do |id| 
        @movie_info = db.execute('SELECT * FROM movie_db WHERE id = ?', id).first
        erb :edit_movie
    end

    post '/movie/edit/:id' do |id| 
        title = params["title"]
        description = params["description"]
        year = params["year"]
        movie_image = params["movie_image"]
        genre = params["genre"]
        director = params["director"]

        query = "UPDATE movie_db SET title = ?, description = ?, year = ?, movie_image = ?, genre = ?, director = ? WHERE id = ?"
        db.execute(query, title, description, year, movie_image, genre, director, id)
        redirect '/'
    end
end
