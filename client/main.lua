local ClientState = {
  lastRequestAt = 0,
}

local cooldownMs = 20000
if Config.Target and type(Config.Target.cooldownMs) == 'number' then
  cooldownMs = Config.Target.cooldownMs
end

local function RequestAssistance(bellId, targetCoords)
  if not bellId or not Config.Bells[bellId] then return end
  if not targetCoords then return end

  local now = GetGameTimer()
  if (now - ClientState.lastRequestAt) < cooldownMs then
    if type(lib) == 'table' and type(lib.notify) == 'function' then
      lib.notify({ title = Config.Notification.title, description = 'Please wait before requesting again.', type = 'error', duration = 4000 })
    end
    return
  end
  ClientState.lastRequestAt = now

  TriggerServerEvent('businessbell:serverRequest', {
    bellId = bellId,
    coords = { x = targetCoords.x, y = targetCoords.y, z = targetCoords.z }
  })
end

RegisterNetEvent('businessbell:clientReceive', function(payload)
  if not payload or not payload.coords or not payload.bellId then return end

  local resourceName = GetCurrentResourceName()

  local nPayload = {
    title = payload.title or Config.Notification.title,
    description = payload.description or Config.Notification.description,
    type = payload.type or 'inform',
    icon = payload.icon or Config.Notification.icon,
    duration = payload.duration or Config.Notification.duration
  }

  exports[resourceName]:NotifyOnDuty(nPayload)
end)

local function GetTargetResource()
  local choice = (Config.Target and Config.Target.resource) or 'auto'
  if choice == 'ox_target' and GetResourceState('ox_target') == 'started' then return 'ox_target' end
  if choice == 'qb-target' and GetResourceState('qb-target') == 'started' then return 'qb-target' end
  if choice == 'auto' then
    if GetResourceState('ox_target') == 'started' then return 'ox_target' end
    if GetResourceState('qb-target') == 'started' then return 'qb-target' end
  end
  return nil
end

RegisterNetEvent('businessbell:clientRequestAssistance', function(data)
  local bellId = data and data.bellId
  if not bellId or not Config.Bells[bellId] then return end
  RequestAssistance(bellId, Config.Bells[bellId].coords)
end)

CreateThread(function()
  local target = GetTargetResource()
  if not target then return end

  for bellId, bell in pairs(Config.Bells) do
    local coords = bell.coords
    local radius = bell.radius or 2.0
    local label = (Config.Target and Config.Target.label) or 'Request Assistance'

    if target == 'ox_target' then
      exports.ox_target:addSphereZone({
        coords = coords,
        radius = radius,
        options = {
          {
            name = 'businessbell_' .. bellId,
            icon = 'fa-solid fa-bell',
            label = label,
            onSelect = function()
              RequestAssistance(bellId, coords)
            end
          }
        }
      })
    elseif target == 'qb-target' then
      exports['qb-target']:AddCircleZone({
        name = 'businessbell_' .. bellId,
        coords = coords,
        radius = radius,
        useZ = true,
        options = {
          {
            type = 'client',
            event = 'businessbell:clientRequestAssistance',
            icon = 'fas fa-bell',
            label = label,
            bellId = bellId
          }
        }
      })
    end
  end
end)


