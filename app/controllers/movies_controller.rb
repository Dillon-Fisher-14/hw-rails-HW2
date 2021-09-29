class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      
      @all_ratings = ['G','PG','PG-13','R']
      @initial_ratings = {"G"=>1, "PG"=>1, "PG-13"=>1, "R"=>1}
      
      restfulRelaunch = false
      
      #Ratings
      if params[:ratings]
        @ratings = params[:ratings]
        session[:ratings] = params[:ratings]
      else
        if session[:ratings]
          @ratings = session[:ratings]
          restfulRelaunch = true
        else
          @ratings = @initial_ratings
          session[:ratings] = @initial_ratings
        end
      end
      
      #Sorting By
      if params[:sortingBy]
        @sortingBy = params[:sortingBy]
        session[:sortingBy] = params[:sortingBy]
      elsif session[:sortingBy]
        @sortingBy = session[:sortingBy]
        restfulRelaunch = true
      end
      
      if @sortingBy == "title"
        @title_class = 'hilite bg-warning'
      elsif @sortingBy == "release_date"
        @release_date_class = 'hilite bg-warning'
      end
      
      #Relaunch with new parameters if needed
      if restfulRelaunch
        flash.keep
        redirect_to movies_path(:ratings => @ratings, :sortingBy => @sortingBy)
        return
      end
      
      
      #Set display parameter
      @movies = Movie.with_ratings(@ratings.keys)

      @check_box_checked = {'G' => false,'PG' => false,'PG-13' => false,'R' => false}
      for rating in @ratings.keys do
        @check_box_checked[rating] = true
      end
      
      @movies = @movies.order(@sortingBy)
      
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end