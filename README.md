# businessbell (QB/ESX/QBX) - Assistance Bell

## What it does
- Place one or more **bells** (coords + radius) in `config.lua`.
- Players use **ox_target** or **qb-target** at the bell (look at it, choose "Request Assistance").
- On-duty staff for that bell’s jobs get an `ox_lib` notification.

## Configure bells + jobs
Edit `config.lua`:
- `Config.Bells[<bellId>].coords` and `radius` (target zone at the bell).
- `Config.Bells[<bellId>].jobs = { { name = 'jobName', minGrade = 0 }, ... }`

## Target (ox_target / qb-target)
- **Config.Target.resource**: `'ox_target'`, `'qb-target'`, or `'auto'` (detect which is started).
- **Config.Target.label**: Text shown in the target menu (e.g. "Request Assistance").
- **Config.Target.cooldownMs**: Cooldown between requests.

Ensure **ox_target** or **qb-target** starts before this resource.

## Install
- Add resource to your server; start after your framework and target script.
- Requires `ox_lib` for notifications.
