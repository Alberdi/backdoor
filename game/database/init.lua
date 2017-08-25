
local json = require 'dkjson'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'

local DB = {}

-- Pending issues:
-- + Support range inputs (min + length)
-- + Use range input to min/max pairs in transformers
-- + 'list' should actually be 'mixedlist'

local SCHEMA = {
  body = {
    { id = 'extends', name = "Prototype", type = "enum", options = 'body' },
    { id = 'hp', name = "Hit Points", type = "integer", range = {1,999} }
  },
  actor = {
    { id = 'extends', name = "Prototype", type = "enum", options = 'actor' },
    { id = 'behavior', name = "Behavior", type = "enum",
      options = {'player','random_walk'} }
  },
  sector = {
    { id = 'width', name = "Size Width", type = "integer", range = {8,128} },
    { id = 'height', name = "Size Height", type = "integer", range = {8,128} },
    { id = 'margin-width', name = "Margin Width", type = "integer",
      range = {0,16} },
    { id = 'margin-height', name = "Margin Height", type = "integer",
      range = {0,16} },
    { id = 'transformers', name = "Transformer", type = 'list' }
  }
}

local domains = {}

local spec_meta = {}

function spec_meta:__index(key)
  local extends = rawget(self, "extends")
  if extends then
    return domains[extends][key]
  end
end

function DB.schemaFor(domain_name)
  return ipairs(SCHEMA[domain_name] or TRANSFORMERS[domain_name].schema)
end

function DB.loadDomain(domain_name)
  local domain = domains[domain_name] if not domain then
    -- FIXME: hardcoded base path
    local filepath = ("game/database/%s.json"):format(domain_name)
    local file = assert(io.open(filepath, 'r'))
    local _, err
    domain, _, err = json.decode(file:read('*a'))
    file:close()
    assert(domain, err)
    for k,spec in pairs(domain) do
      setmetatable(spec, spec_meta)
    end
    domains[domain_name] = domain
  end
  return domain
end

function DB.loadSpec(domain_name, spec_name)
  return DB.loadDomain(domain_name)[spec_name]
end

function DB.save()
  for name,domain in pairs(domains) do
    local filepath = ("game/database/%s.json"):format(name)
    local file = assert(io.open(filepath, 'w'))
    local data = json.encode(domain, { indent = true })
    file:write(data)
    file:close()
  end
end

return DB

