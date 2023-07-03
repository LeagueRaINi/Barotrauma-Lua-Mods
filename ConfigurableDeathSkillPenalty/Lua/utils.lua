local utils = {}

utils.array_find = function(arr, fn)
  for value in arr do
    if fn(value) then
      return value
    end
  end
  return nil
end

utils.str_starts_with = function(text, prefix)
  return text:find(prefix, 1, true) == 1
end

utils.split = function(str, sep)
  local fields = {}
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, function(c) fields[#fields + 1] = c end)
  return fields
end

utils.SendChatMessage = function(client, text)
  text = tostring(text)
  Game.SendDirectChatMessage(ChatMessage.Create("", text, ChatMessageType.Default), client)
end

return utils