require 'open-uri'
require 'json'

class MoviesController < ApplicationController
  def search
    query = params[:query]
    movie_details = fetch_movie_details(query)

    if movie_details
      render json: { success: true, movie: movie_details }, status: :ok
    else
      render json: { success: false, error: 'Movie not found' }, status: :not_found
    end
  end

  def create
    @list = List.find(params[:list_id])
    movie_params = {
      title: params[:bookmark][:movie_title],
      overview: params[:bookmark][:movie_overview],
      rating: params[:bookmark][:movie_rating],
      poster_url: params[:bookmark][:movie_poster_url]
    }

    @movie = Movie.find_or_initialize_by(title: movie_params[:title])
    @movie.assign_attributes(movie_params)

    if @movie.save
      @bookmark = @list.bookmarks.create(movie: @movie, comment: params[:bookmark][:comment])
      if @bookmark.persisted?
        redirect_to @list, notice: 'Movie was successfully added to the list.'
      else
        render :new
      end
    else
      render :new
    end
  end

  private

  def fetch_movie_details(query)
    api_key = 'ed0fae3f'
    api_url = "http://www.omdbapi.com/?t=#{URI.encode(query)}&apikey=#{api_key}"

    response = open(api_url).read
    movie_data = JSON.parse(response)

    {
      title: movie_data["Title"],
      overview: movie_data["Plot"],
      rating: movie_data["imdbRating"],
      poster_url: movie_data["Poster"]
    } if movie_data["Response"] == "True"
  end

  def movie_params
    params.require(:movie).permit(:title, :overview, :rating, :poster_url, :comment)
  end

end
