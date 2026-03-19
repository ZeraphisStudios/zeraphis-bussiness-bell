Config.FrameworkCompat = {
  qb = {
    onDutyField = 'onduty'
  },
  qbox = {
    onDutyField = 'onduty'
  },
  esx = {
    sharedObjectResource = 'es_extended',
    sharedObjectFn = 'getSharedObject',

    dutyExport = {
      enabled = true,
      resource = 'esx_society',
      functionName = 'IsOnDuty',
      exportArgs = { 'jobName' }
    },

    fallbackToOnDuty = true
  }
}
