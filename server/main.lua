local function DetectFramework()
  if GetResourceState('qb-core') == 'started' then
    return 'qb', exports['qb-core']:GetCoreObject()
  end

  if GetResourceState('qbx_core') == 'started' then
    return 'qbx', exports['qbx_core']:GetCoreObject()
  end

  if GetResourceState('qbox_core') == 'started' then
    return 'qbox', exports['qbox_core']:GetCoreObject()
  end

  if GetResourceState('es_extended') == 'started' then
    return 'esx', exports['es_extended']:getSharedObject()
  end

  return nil, nil
end

local FrameworkName, Core = DetectFramework()

local DutyCache = {}
local LastDispatchByPlayer = {}

local function GetJobFromQB(source)
  if not Core then return nil end

  local player = Core.Functions.GetPlayer(source)
  if not player then return nil end

  local job = player.PlayerData and player.PlayerData.job
  if not job then return nil end

  local compat = (Config.FrameworkCompat and Config.FrameworkCompat[FrameworkName]) or Config.FrameworkCompat.qb
  local ondutyField = (compat and compat.onDutyField) or 'onduty'
  local onduty = job[ondutyField]
  if onduty == nil then
    onduty = job.onDuty or job.isBoss
  end

  local gradeLevel = nil
  if job.grade and job.grade.level ~= nil then
    gradeLevel = tonumber(job.grade.level)
  elseif job.grade and job.grade ~= nil and type(job.grade) ~= 'table' then
    gradeLevel = tonumber(job.grade)
  end

  return {
    name = job.name,
    onduty = onduty == true,
    gradeLevel = gradeLevel
  }
end

local function BuildExportArgs(configArgs, context)
  if type(configArgs) ~= 'table' then return {} end
  local args = {}
  for _, token in ipairs(configArgs) do
    if token == 'jobName' then
      args[#args + 1] = context.jobName
    elseif token == 'src' then
      args[#args + 1] = context.src
    elseif token == 'job' then
      args[#args + 1] = context.job
    else
      args[#args + 1] = token
    end
  end
  return args
end

local function GetOnDutyESX(jobName, source, jobObj)
  local esxCfg = Config.FrameworkCompat and Config.FrameworkCompat.esx or nil
  if not esxCfg then return false end

  if jobObj then
    if jobObj.onduty ~= nil then return jobObj.onduty == true end
    if jobObj.onDuty ~= nil then return jobObj.onDuty == true end
    if jobObj.isBoss ~= nil then return jobObj.isBoss == true end
  end

  local dutyExport = esxCfg.dutyExport and esxCfg.dutyExport.enabled and esxCfg.dutyExport
  if dutyExport and dutyExport.resource and dutyExport.functionName then
    local okExports, exportsObj = pcall(function()
      return exports[dutyExport.resource]
    end)

    if okExports and exportsObj and exportsObj[dutyExport.functionName] then
      local cacheKey = ('%s:%s:%s'):format(source, jobName or 'nil', dutyExport.functionName)
      if DutyCache[cacheKey] ~= nil then return DutyCache[cacheKey] end

      local args = BuildExportArgs(dutyExport.exportArgs, {
        jobName = jobName,
        src = source,
        job = jobObj
      })

      local ok, result = pcall(function()
        return exportsObj[dutyExport.functionName](table.unpack(args))
      end)

      local onduty = false
      if ok and type(result) == 'boolean' then
        onduty = result
      end

      DutyCache[cacheKey] = onduty
      SetTimeout(30000, function()
        DutyCache[cacheKey] = nil
      end)

      return onduty == true
    end
  end

  return esxCfg.fallbackToOnDuty == true
end

local function GetJobFromESX(source)
  if not Core then return nil end

  local xPlayer = Core.GetPlayerFromId(source)
  if not xPlayer or not xPlayer.job then return nil end

  local job = xPlayer.job
  local gradeLevel = tonumber(job.grade) or nil

  return {
    name = job.name,
    onduty = GetOnDutyESX(job.name, source, job),
    gradeLevel = gradeLevel
  }
end

local function PlayerMeetsJobRequirements(jobData, bell)
  if not jobData or not bell or not bell.jobs then return false end

  for _, req in ipairs(bell.jobs) do
    if req.name == jobData.name then
      if jobData.onduty ~= true then
        return false
      end

      if req.minGrade ~= nil and jobData.gradeLevel ~= nil then
        if tonumber(jobData.gradeLevel) < tonumber(req.minGrade) then
          return false
        end
      end

      return true
    end
  end

  return false
end

local function GetAllPlayerSources()
  if FrameworkName == 'esx' then
    local players = {}
    for _, id in ipairs(GetPlayers()) do
      players[#players + 1] = id
    end
    return players
  end

  if Core and Core.Functions and Core.Functions.GetPlayers then
    return Core.Functions.GetPlayers()
  end

  return GetPlayers()
end

local function GetJobDataForSource(source)
  if FrameworkName == 'esx' then
    return GetJobFromESX(source)
  end

  return GetJobFromQB(source)
end

local function NormalizeCoords(input)
  if type(input) ~= 'table' then return nil end
  local x, y, z = tonumber(input.x), tonumber(input.y), tonumber(input.z)
  if not x or not y or not z then return nil end
  return vector3(x, y, z)
end

local function DispatchToOnDuty(bellId, coords, requesterSource)
  local bell = Config.Bells and Config.Bells[bellId] or nil
  if not bell then return end

  local recipients = {}
  for _, src in ipairs(GetAllPlayerSources()) do
    local jobData = GetJobDataForSource(src)
    if PlayerMeetsJobRequirements(jobData, bell) then
      recipients[#recipients + 1] = src
    end
  end

  for _, src in ipairs(recipients) do
    TriggerClientEvent('businessbell:clientReceive', src, {
      bellId = bellId,
      coords = { x = coords.x, y = coords.y, z = coords.z },

      title = Config.Notification.title,
      headline = Config.Notification.headline,
      description = Config.Notification.description,
      type = Config.Notification.type or 'inform'
    })
  end
end

RegisterNetEvent('businessbell:serverRequest', function(data)
  local src = source
  if type(data) ~= 'table' then return end

  local bellId = data.bellId
  local coords = NormalizeCoords(data.coords)

  if not bellId or not Config.Bells[bellId] then return end
  if not coords then
    coords = Config.Bells[bellId].coords
  end

  local bell = Config.Bells[bellId]
  if not bell then return end

  local now = GetGameTimer()
  local key = ('%s:%s'):format(src, bellId)
  local last = LastDispatchByPlayer[key] or 0

  local cooldownMs = (Config.GlobalCooldownMs or 15000)
  if Config.Target and Config.Target.cooldownMs then
    cooldownMs = math.max(cooldownMs, Config.Target.cooldownMs)
  end

  if (now - last) < cooldownMs then return end
  LastDispatchByPlayer[key] = now

  local ped = GetPlayerPed(src)
  local callerCoords = ped and GetEntityCoords(ped) or nil
  if callerCoords then
    local dist = #(callerCoords - coords)
    if dist > (Config.MaxRequestDistanceFromPlayer or 200.0) then
      return
    end
  end

  DispatchToOnDuty(bellId, coords, src)
end)

CreateThread(function()
  if not FrameworkName then
    print('[businessbell] No supported framework detected (qb-core/qbx_core/qbox_core/es_extended).')
  end
end)

AddEventHandler('onResourceStart', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then return end

  print('Framework Detected: ' .. (FrameworkName or 'unknown'))
  print([[
                                     __                    
                                    /\ \      __           
 ____      __   _ __    __     _____\ \ \___ /\_\    ____  
/\_ ,`\  /'__`\/\`'__\/'__`\  /\ '__`\ \  _ `\/\ \  /',__\ 
\/_/  /_/\  __/\ \ \//\ \L\.\_\ \ \L\ \ \ \ \ \ \ \/\__, `\
  /\____\ \____\\ \_\\ \__/.\_\\ \ ,__/\ \_\ \_\ \_\/\____/
  \/____/\/____/ \/_/ \/__/\/_/ \ \ \/  \/_/\/_/\/_/\/___/ 
                                 \ \_\                     
                                  \/_/   
                                                    
        Zeraphis Business Bell loaded successfully.
        Thank you for choosing Zeraphis Studios - https://discord.gg/HcqNCypSAJ
  ]])
end)

