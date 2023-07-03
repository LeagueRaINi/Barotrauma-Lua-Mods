-- the client doesnt need a config so we will just use a local variable here
local skillPenalty = 0.75

Networking.Receive("DeathSkillPenalty.Sync", function(msg, _)
  skillPenalty = msg.ReadSingle();
end)

Hook.Patch(
  "Barotrauma.TextManager",
  "GetWithVariable",
  {
    "System.String",
    "System.String",
    "Barotrauma.LocalizedString",
    "Barotrauma.FormatCapitals",
  },
  function(instance, ptable)
    if ptable["tag"] == "respawnskillpenalty" then
      ptable["value"] = tostring(skillPenalty * 100)
    end
end, Hook.HookMethodType.Before)

-- Send a 'ping' to the server to get the current skill penalty
Networking.Send(Networking.Start("DeathSkillPenalty.Sync"))