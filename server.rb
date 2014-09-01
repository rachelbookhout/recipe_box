require 'sinatra'
require 'pg'

configure :development do
  require 'pry'
end

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end


def find_recipes
  answer = db_connection do |conn|
    conn.exec("SELECT * FROM recipes
              ORDER BY name ASC")
  end
answer.to_a
end

def get_recipe_info(id)
  info =  db_connection do |conn|
            conn.exec("SELECT recipes.name,recipes.description, recipes.instructions, ingredients.name AS ingredients FROM recipes
            JOIN ingredients on recipes.id = ingredients.recipe_id
            WHERE recipes.id = $1", [id])
          end
  info.to_a
end





get '/recipes' do
#shows a list of all recipes, all recipes link to their unique page
@recipes = find_recipes
erb :index
end

get'/recipes/:recipe_id' do
id = params[:recipe_id]
@recipe_info = get_recipe_info(id)
#lists off the recipe name, description and instructions. lists the ingredients used for the recipe.
erb :show
end
