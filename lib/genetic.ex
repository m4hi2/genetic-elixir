defmodule Genetic do
  def initialize(genotype) do
    for _ <- 1..100, do: genotype.()
  end

  def evaluate(population, fitness_function) do
    population
    |> Enum.sort_by(fitness_function, &>=/2)
  end

  def select(population) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  def crossover(population) do
    population
    |> Enum.reduce([], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(length(p1))
      {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
      {c1, c2} = {h1 ++ t2, h2 ++ t1}
      [c1, c2 | acc]
    end)
  end

  def mutation(population) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end

  def run(fitness_function, genotype, max_fitness) do
    population = initialize(genotype)

    population
    |> evolve(fitness_function, genotype, max_fitness)
  end

  def evolve(population, fitness_function, genotype, max_fitness) do
    population = evaluate(population, fitness_function)
    best = hd(population)
    IO.write("\rCurrent Best: #{fitness_function.(best)}")

    if fitness_function.(best) == max_fitness do
      best
    else
      population
      |> select()
      |> crossover()
      |> mutation()
      |> evolve(fitness_function, genotype, max_fitness)
    end
  end
end
