local function NotifyOnDuty(payload)
  if type(lib) ~= 'table' or type(lib.notify) ~= 'function' then return end

  lib.notify({
    title = payload.title or Config.Notification.title,
    description = payload.description or '',
    type = payload.type or 'inform',
    icon = payload.icon or Config.Notification.icon,
    duration = payload.duration or Config.Notification.duration
  })
end

exports('NotifyOnDuty', NotifyOnDuty)
