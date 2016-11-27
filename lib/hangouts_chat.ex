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
        |> Enum.filter(&(is_valid_text_message?(&1)))
        |> Enum.map(&(extract_metadata(&1)))
        |> Enum.reduce([], &(combine_messages_for_user(&1, &2)))
        |> Enum.reduce(%{}, &(build_user_map(&1, &2)))
        |> Map.get(user_id)
        |> Markov.build_markov_map
    end

    defp is_valid_text_message?(entry) do
      message = get_in(entry, ["chat_message", "message_content"])
      get_in(entry, ["event_type"]) == "REGULAR_CHAT_MESSAGE" && Map.has_key?(message, "segment")
    end

    defp extract_metadata(entry) do
        user_id = get_in(entry, ["sender_id","chat_id"])
        segment = get_in(entry, ["chat_message", "message_content", "segment"])
        text = segment |> List.first |> Map.get("text")
        %{:user_id => user_id, :text => text}
    end

    defp build_user_map(entry, acc) do
        %{:user_id => user_id, :text => text} = entry
        Map.update(acc, user_id, [text], &([text | &1]))
    end

    defp combine_messages_for_user(entry, []) do [entry] end
    defp combine_messages_for_user(entry, [head | tail]) do
        %{:user_id => user_id, :text => text} = entry
        %{:user_id => previous_user_id} = head

        if user_id == previous_user_id do
          [Map.update!(head, :text, &(&1 <> " " <> text)) | tail]
        else
          [entry | [head | tail]]
        end
    end

end