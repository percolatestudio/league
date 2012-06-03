# Veeeeeeery simple cron job singleton
# ticks every 1 minute, set a job to go every X ticks.
class Cron
  # by default tick every 1 minute
  constructor: (interval = 60 * 1000) ->
    @jobs = []
    Meteor.setInterval (=> @tick()), interval
  
  add_job: (every_x_ticks, fn) ->
    @jobs.push {fn: fn, every: every_x_ticks, count: 0}
  
  tick: () ->
    for job in @jobs
      job.count += 1
      if job.count == job.every
        job.fn()
        job.count = 0


Cron.instance = new Cron()

# this is Ok when you have 60s ticks
Cron.instance.add_job 1, -> console.log 'Cron: tick'