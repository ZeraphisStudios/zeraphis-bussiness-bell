Config = {}

Config.UseFrameworkAutoDetect = true -- Use the framework auto detect

Config.Bells = {
  ['example_bell'] = { -- Example Bell ID
    label = 'Example Bell Label 1', -- Example Bell Label
    coords = vector3(-50.0, -1100.0, 26.4), -- Example Bell Coords
    radius = 2.0, -- Example Bell Radius
    jobs = {
      { name = 'JOB_NAME', minGrade = 0 } -- Example Job Name and Minimum Grade
    }
  },
  ['example_bell_2'] = { -- Example Bell ID
    label = 'Example Bell Label 2', -- Example Bell Label
    coords = vector3(25.7, -1347.3, 29.5), -- Example Bell Coords
    radius = 2.0, -- Example Bell Radius
    jobs = {
      { name = 'JOB_NAME', minGrade = 0 } -- Example Job Name and Minimum Grade
    }
  },
  ['example_bell_3'] = { -- Example Bell ID
    label = 'Example Bell Label 3', -- Example Bell Label
    coords = vector3(-339.5, -136.9, 39.0), -- Example Bell Coords
    radius = 2.0, -- Example Bell Radius
    jobs = {
      { name = 'JOB_NAME', minGrade = 0 } -- Example Job Name and Minimum Grade
    }
  },
  ['example_bell_4'] = { -- Example Bell ID
    label = 'Example Bell Label 4', -- Example Bell Label
    coords = vector3(-706.0, 269.0, 83.1), -- Example Bell Coords
    radius = 2.0, -- Example Bell Radius
    jobs = {
      { name = 'JOB_NAME', minGrade = 0 } -- Example Job Name and Minimum Grade
    }
  },
  ['example_bell_5'] = { -- Example Bell ID
    label = 'Example Bell Label 5', -- Example Bell Label
    coords = vector3(-1195.0, -1190.0, 7.7), -- Example Bell Coords
    radius = 2.0, -- Example Bell Radius
    jobs = {
      { name = 'JOB_NAME', minGrade = 0 } -- Example Job Name and Minimum Grade
    }
  }
}

Config.Target = {
  resource = 'auto', -- 'ox_target' | 'qb-target' | 'auto'
  label = 'Request Assistance', -- Label for the target
  cooldownMs = 20000 -- Cooldown for the target
}

Config.Notification = {
  title = 'Zeraphis Business Bell', -- Title for the notification
  headline = 'ASSISTANCE REQUIRED', -- Headline for the notification
  description = 'Someone needs help at the counter.', -- Description for the notification
  icon = 'brain', -- Icon for the notification
  duration = 10000 -- Duration for the notification
}

Config.GlobalCooldownMs = 15000 -- Global cooldown to prevent spam (per caller + per bell).

Config.MaxRequestDistanceFromPlayer = 200.0 -- Basic anti-spam/grief guard: assistance location should be near the caller.