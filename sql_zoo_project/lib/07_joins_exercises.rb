# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
    SELECT title
    FROM movies
      JOIN castings
        ON castings.movie_id = movies.id
    WHERE castings.actor_id = 
      (SELECT id
      FROM actors
      WHERE name = 'Harrison Ford');
  SQL
  # What is the smallest query you can use first and use?????
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
    SELECT movies.title
    FROM movies
      JOIN castings
        ON castings.movie_id = movies.id
      JOIN actors
        ON castings.actor_id = actors.id
    WHERE actors.name = 'Harrison Ford' AND castings.ord != 1;
  SQL
  # SELECT title
  # FROM movies
  #   JOIN castings
  #     ON castings.movie_id = movies.id
  # WHERE castings.actor_id = 
  #   (SELECT id
  #   FROM actors
  #   WHERE name = 'Harrison Ford'
  #   ) AND ord != 1
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
    SELECT movies.title, actors.name
    FROM movies
      JOIN castings
        ON movies.id = castings.movie_id
      JOIN actors
        ON castings.actor_id = actors.id
    WHERE movies.yr = 1962 AND castings.ord = 1    
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
    SELECT movies.yr, COUNT(movies.title)
    FROM castings
    JOIN actors
      ON actors.id = castings.actor_id
    JOIN movies
      ON movies.id = castings.movie_id
    WHERE
      actors.name = 'John Travolta'
    GROUP BY yr
    HAVING COUNT(title) >= 2
  SQL
end

#subquery = All films Julie was in
#select title and leading actor
#preface with table. prefixes
#WHERE movies.title IN (subquery where we only want actor name Julie
# and castings.ord = 1 for leading role)
def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  
  execute(<<-SQL)
    SELECT movies.title, actors.name
    FROM actors
      JOIN castings ON castings.actor_id = actors.id
      JOIN movies ON movies.id = castings.movie_id
    WHERE movies.id IN
      (SELECT movie_id
      FROM castings
        JOIN actors on actors.id = castings.actor_id
      WHERE actors.name = 'Julie Andrews')
    AND castings.ord = 1;
  SQL
  # SELECT movies.title, actors.name
  # FROM actors
  #   JOIN castings
  #     ON castings.actor_id = actors.id
  #   JOIN movies
  #     ON movies.id = castings.movie_id
  # WHERE movies.title IN (
  #     SELECT movies.title
  #     FROM movies
  #     JOIN castings
  #       ON castings.movie_id = movies.id
  #     JOIN actors
  #       ON actors.id = castings.actor_id
  #     WHERE actors.name = 'Julie Andrews'
  #     )
  # AND castings.ord = 1;
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
    SELECT actors.name
    FROM actors
      JOIN castings ON castings.actor_id = actors.id
    WHERE castings.ord = 1
    GROUP BY actors.name
    HAVING COUNT(castings.movie_id) >= 15
    ORDER BY actors.name
  SQL
  # Filter first by WHERE applying to all rows
  # Then filter by GROUP BY especially when applying an aggregate function
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
    SELECT movies.title, COUNT(castings.actor_id)
    FROM movies
      JOIN castings ON castings.movie_id = movies.id
    WHERE movies.yr = 1978
    GROUP BY movies.title
    ORDER BY COUNT(castings.actor_id) DESC, movies.title
  SQL
  # column "movies.title" must appear in the GROUP BY clause 
  # or be used in an aggregate function. Or else we don't have access
  # to Select it at the end
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
    SELECT actors.name
    FROM actors
      JOIN castings ON castings.actor_id = actors.id
      JOIN movies ON movies.id = castings.movie_id
    WHERE movies.title IN
      (SELECT movies.title
      FROM movies
        JOIN castings ON movies.id = castings.movie_id
        JOIN actors ON actors.id = castings.actor_id
      WHERE actors.name = 'Art Garfunkel'
      )
    AND actors.name != 'Art Garfunkel'
  SQL
end
