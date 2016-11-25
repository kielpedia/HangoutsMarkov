defmodule Hangouts_Chat do

    def get_markov_map_from_chat(file_path, chat_id, user_id) do
        file_path
        |> File.read!
        |> Poison.decode
        |> elem(1)
        |> Map.get("conversation_state")
        |> Enum.filter(&(get_in(&1, ["conversation_id","id"]) == chat_id))
        |> Enum.map(&(get_in(&1, ["conversation_state","event"])))
        |> List.first
        |> Enum.filter(&(get_in(&1, ["event_type"]) == "REGULAR_CHAT_MESSAGE"))
        |> Enum.reduce(%{}, &(build_user_map(&1, &2)))
        |> Map.get(user_id)
        |> Markov.build_markov_map
    end


    def build_user_map(entry, acc) do
        user_id = get_in(entry, ["sender_id","chat_id"])
        message = get_in(entry, ["chat_message", "message_content"])
        if Map.has_key?(message, "segment") do
          text = message |> Map.get("segment") |> List.first |> Map.get("text")
          Map.update(acc, user_id, [text], &([text | &1]))
        else
          acc
        end
    end
end