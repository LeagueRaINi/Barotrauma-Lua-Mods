local utils = require "utils"

local function sendDeathSkillPenaltyToClient(client)
  local message = Networking.Start("DeathSkillPenalty.Sync")
  message.WriteSingle(CDSP.Config.deathSkillPenalty)
  Networking.Send(message, client.Connection)
end

Hook.Add("roundStart", "DeathSkillPenalty.roundStart", function()
  for connectedClient in Client.ClientList do
    sendDeathSkillPenaltyToClient(connectedClient)
  end
end)

Hook.Patch(
  "Barotrauma.Networking.RespawnManager",
  "ReduceCharacterSkills",
  {
    "Barotrauma.CharacterInfo",
  },
  function(instance, ptable)
    ptable.PreventExecution = true

    -- todo! not 100% sure this will just work so that will need testing
    if CDSP.Config.deathSkillPenalty == 0 then end

    local characterInfo = ptable["characterInfo"]
    if characterInfo == nil or characterInfo.Job == nil then end

    for skill in characterInfo.Job.GetSkills() do
      local skillPrefab = utils.array_find(characterInfo.Job.Prefab.Skills, function(x)
        if x.Identifier == skill.Identifier then
          return true
        end
      end)
          
      if not (skillPrefab == nil or skill.Level < skillPrefab.LevelRange.End) then
        skill.Level = math.lerp(skill.Level, skillPrefab.LevelRange.End, CDSP.Config.deathSkillPenalty)
      end
    end
end, Hook.HookMethodType.Before)

Hook.Add("chatMessage", "CDSP.chatMessage", function(message, client)
  if not utils.str_starts_with(message, CDSP.Config.command) then return end

  local args = utils.split(message, " ")
  if #args < 2 then
    utils.SendChatMessage(client, "Usage: " .. CDSP.Config.command .. " <get|set> [value]")
    return true
  end

  local option = args[2]
  if option == "get" then
    utils.SendChatMessage(client, "Death skill penalty is set to: " .. CDSP.Config.deathSkillPenalty)
  elseif option == "set" then
    if #args < 3 then
      utils.SendChatMessage(client, "Usage: " .. CDSP.Config.command .. " set <value>")
      return true
    end

    local value = tonumber(args[3])
    if value < 0 or value > 1 then
      utils.SendChatMessage(client, "Invalid value: " .. value)
      return true
    end

    CDSP.Config.deathSkillPenalty = value
    File.Write(CDSP.Path .. "/config.json", json.serialize(CDSP.Config))
    
    Game.SendMessage("Death skill penalty changed to " .. (value * 100) .. "%!", ChatMessageType.Server)

    for connectedClient in Client.ClientList do
      sendDeathSkillPenaltyToClient(connectedClient)
    end
  else
    utils.SendChatMessage(client, "Invalid option: " .. option)
  end

  return true
end)