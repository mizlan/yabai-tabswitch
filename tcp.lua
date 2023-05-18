local net = require('net')
local childProcess = require('childprocess')
local json = require('json')

local function run(command, args, callback)
  local cenv = {}
  for k, v in process.env.iterate() do
    cenv[k] = v
  end
  local child = childProcess.spawn(command, args, { env = cenv })
  local output = {}
  child.stdout:on('data', function(data) table.insert(output, data) end)
  child:on('exit', function(exitcode)
    if callback then
      callback(table.concat(output))
    end
  end)
end

local function defaultdict(callable)
  local T = {}
  setmetatable(T, {
    __index = function(T, key)
      local val = rawget(T, key)
      if not val then
        rawset(T, key, callable())
      end
      return rawget(T, key)
    end
  })
  return T
end

local mq = defaultdict(function() return {} end)
local idset = {}
local curapp = nil
local curptr = 1

local function filter_inplace(arr, func)
  local new_index = 1
  local size_orig = #arr
  for old_index, v in ipairs(arr) do
    if func(v, old_index) then
      arr[new_index] = v
      new_index = new_index + 1
    end
  end
  for i = new_index, size_orig do arr[i] = nil end
end

local function refresh()
  local mq2 = defaultdict(function() return {} end)
  local idset2 = {}
  local function onOut(s)
    local data = json.parse(s)
    for i, e in ipairs(data) do
      table.insert(mq2[e.app], { id = e.id, space = e.space })
      idset2[e['id']] = e.space
    end
    for app, info in pairs(mq) do
      filter_inplace(info, function(e)
        -- can be nil
        local v = idset2[e.id]
        idset[e.id] = v
        -- space couldve changed
        e.space = v
        return v
      end)
    end
    for app, info in pairs(mq2) do
      for _, inst in ipairs(info) do
        if not idset[inst.id] then
          table.insert(mq[app], inst)
          idset[inst.id] = true
        end
      end
    end
    p(idset)
    p(mq)
  end
  run('yabai', { '-m', 'query', '--windows' }, onOut)
end

local function focusinfo(e)
  run('yabai', { '-m', 'space', '--focus', e.space }, function()
    run('yabai', { '-m', 'window', '--focus', e.id })
  end)
end

local function cycle()
  if curapp == nil then return end
  curptr = curptr + 1
  local n = #mq[curapp]
  if curptr > n then
    curptr = curptr - n
  end
  if mq[curapp][curptr] == nil then return end
  focusinfo(mq[curapp][curptr])
end

local function go(app)
  curapp = app
  local appinfo = mq[app]
  if appinfo == nil or #appinfo == 0 then return end
  curptr = 1
  local e = appinfo[curptr]
  focusinfo(e)
end

local server = net.createServer(function(client)
  -- print("client connected")

  -- Add some listenners for incoming connection
  client:on("error", function(err)
    print("Client read error: " .. err)
    client:close()
  end)

  client:on("data", function(data)
    local cmd = string.sub(data, 1, 1)
    if cmd == 'r' then
      refresh()
    elseif cmd == 'c' then
      cycle()
    elseif cmd == 'g' then
      go(string.sub(data, 2, -2))
    end
    client:write(data)
  end)

  -- client:on("end", function()
  --   print("client disconnected")
  -- end)
end)

-- Add error listenner for server
server:on('error', function(err)
  if err then error(err) end
end)

server:listen(1337, '127.0.0.1') -- or "server:listen(1234)"
