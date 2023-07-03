CDSP = {}
CDSP.Path = table.pack(...)[1]

if CLIENT then
  dofile(CDSP.Path .. "/Lua/client.lua")
else
  local configPath = CDSP.Path .. "/config.json"
  local config = dofile(CDSP.Path .. "/Lua/config.lua")

  -- Load the config if it exists and make sure it has all the values
  if File.Exists(configPath) then
    local overrides = json.parse(File.Read(configPath))
    for i, _ in pairs(config) do
      if overrides[i] ~= nil then
        config[i] = overrides[i]
      end
    end
  end

  CDSP.Config = config

  -- Overwrite the exisiting config to make sure it always has the latest values
  File.Write(configPath, json.serialize(config))

  dofile(CDSP.Path .. "/Lua/server.lua")
end