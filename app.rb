class App < Sinatra::Base
    enable :sessions

    def db
        return @db if @db
        @db = SQLite3::Database.new('./db/movies.db')
        @db.results_as_hash = true
        return @db
    end

    get '/movie/:id' do |id|
        @movie = db.execute("SELECT * from movie_db WHERE id = ?", id).first
        erb :movie
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
        role = params["role"]
        
        hashed_password = BCrypt::Password.create(password)

        query = 'INSERT INTO login_credentials (username, password, role) VALUES (?,?,?)'
        db.execute(query, username, hashed_password, role)
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
            redirect '/login'
        end

        hashed_password = user['password']

        if BCrypt::Password.new(hashed_password) == password
            session[:user_id] = user['id']
            session[:username] = user['username']
            session[:role] = user['role']
            puts session[:username]
            redirect '/'
        end
    end

    get '/logout' do
        if (session[:username])
            session.clear
            redirect '/'
        end
   end

    get '/add_movie' do 
        erb :add_movie
    end
    
    post '/movie/add' do

        if session[:user_id]

            title = params["title"]
            description = params["description"]
            year = params["year"]
            genre = params["genre"]
            director = params["director"]

        
            query = 'INSERT INTO movie_db (title, description, year, genre, director, added_id) VALUES (?,?,?,?,?,?)'
            db.execute(query, title, description, year, genre, director, session[:user_id])
            redirect "/"
        end
    end

    post '/movie/remove/:id' do |id| 
        if session[:user_id]
            db.execute('DELETE FROM movie_db WHERE id = ?', id)
            redirect "/"
        end
    end

    get '/movie/edit/:id' do |id| 
        @movie_info = db.execute('SELECT * FROM movie_db WHERE id = ?', id).first
        erb :edit_movie
    end

    post '/movie/edit/:id' do |id| 
        if session[:user_id]

            title = params["title"]
            description = params["description"]
            year = params["year"]
            genre = params["genre"]
            director = params["director"]

            query = "UPDATE movie_db SET title = ?, description = ?, year = ?, genre = ?, director = ? WHERE id = ?"
            db.execute(query, title, description, year, genre, director, id)
            redirect '/'

        end
    end
end
