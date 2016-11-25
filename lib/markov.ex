defmodule Markov do

#    BEGIN BUILDER
    def build_markov_map(messages, map \\ %{})
    def build_markov_map(messages, map) when is_list(messages) do
        IO.inspect(messages)
        Enum.reduce(messages, map, &build_markov_map/2)
    end
    def build_markov_map(message, map) do
        message
            |> String.split
#            |> Enum.map(&String.downcase/1) decide whether to keep case insensitivity
            |> get_next_word_count(map)
    end
#   END BUILDER

    def get_next_for_seed(map, word) do
        if Map.has_key?(map, word) do
            next_word = map
                |> Map.get(word)
                |> Map.to_list
                |> Enum.map(fn({start , count}) -> List.duplicate(start, count) end)
                |> List.flatten
                |> Enum.random
                |> modify_string
        else
            nil
        end
    end

    def generate_text_chain(map, seed, max_words, acc \\ "")
    def generate_text_chain(_, nil, _, acc) do String.trim(acc) end
    def generate_text_chain(_, seed, 1, acc) do "#{acc}#{seed}" end
    def generate_text_chain(map, seed, max_words, acc) do
        next_word = get_next_for_seed(map, seed)
        generate_text_chain(map, next_word, max_words - 1, "#{acc}#{seed} ")
    end

    defp get_next_word_count([target | [next | tail]], map) do
        map = Map.update(map, target, %{next => 1},
            fn(next_words) -> Map.update(next_words, next, 1, &(&1 + 1)) end)

        get_next_word_count([next | tail], map)
    end
    defp get_next_word_count([target | []], map) do
        map = Map.update(map, target, %{:end => 1},
            fn(next_words) -> Map.update(next_words, :end, 1, &(&1 + 1)) end)

        get_next_word_count([], map)
    end
    defp get_next_word_count(_, map) do map end

    defp modify_string(:end) do nil end
    defp modify_string(word) do word end

end
