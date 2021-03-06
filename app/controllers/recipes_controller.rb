class RecipesController < ApplicationController
  before_action :current_user

  def index
    if session[:search_terms].nil?
      session[:search_terms] = []
    end

    # This should move to a model?
    duplicate = false
    session[:search_terms].each do |search|
      if search["q"] == params[:q]
        duplicate = true
      end
    end

    if duplicate == false
      session[:search_terms] << {"q" => params[:q], "health1" => params["health1"], "health2" => params["health2"], "diet1" => params["diet1"]}
      if session[:search_terms].length > 5
        session[:search_terms].shift
      end
    end


    @recent_search_terms = session[:search_terms]

    @recipes = EdamamApiWrapper.search_results(params[:q], params[:from], params[:to], params["health1"], params["health2"], params["diet1"])

    if @recipes.empty?
      flash[:notice] = "No recipes match those parameters. Try adjusting your search terms."
    end

    @next_recipes = EdamamApiWrapper.search_results(params[:q], params[:from].to_i + 12, params[:to].to_i + 12, params["health1"], params["health2"], params["diet1"])
  end

  def show
    @recipe = EdamamApiWrapper.specific_search(params[:uri])
    # raise
  end

  def create
    Recipe.create(name: params[:name], user_id: params[:user_id], link: params[:link], image: params[:image], ingredients: params[:ingredients], diet: params[:diet])

    redirect_to favorites_path
  end

  def new
  end

  def update
  end

  def edit
  end

  def destroy
    Recipe.find(params[:id]).delete
    redirect_to favorites_path
  end
end
