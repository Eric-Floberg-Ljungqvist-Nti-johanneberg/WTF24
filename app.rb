class App < Sinatra::Base
    enable :sessions

    def db
        return @db if @db
        @db = SQLite3::Database.new('./db/movies.db')
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
        
        hashed_password = BCrypt::Password.create(password)

        query = 'INSERT INTO login_credentials (username, password) VALUES (?,?)'
        db.execute(query, username, hashed_password)
        redirect "/"
    end

    get '/login' do
        erb :login
    end

    post '/login' do
        
        username = params["username"]
        password = params["password"]

        user = db.execute('SELECT * FROM login_credentials WHERE username = ?', username).first
       
        if user.nil?
            return
        end

        hashed_password = user['password']

        if BCrypt::Password.new(hashed_password) == password
            session[:user_id] = user['id']
            session[:username] = user['username']
            puts session[:username]
            redirect '/'
        end
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

        if !(movie_image == nil)
            File.open('public/img/' + movie_image[:filename], "w") do |f|
                f.write(movie_image[:tempfile].read)
            end
            image_path = "/artwork/" + movie_image[:filename]
            puts(image_path)
        else
            image_path = nil
            puts("No image path")
        end

        query = 'INSERT INTO movie_db (title, description, year, movie_image, genre, director) VALUES (?,?,?,?,?,?)'
        db.execute(query, title, description, year, image_path, genre, director)
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
