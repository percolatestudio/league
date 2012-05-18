playing_states = ['Unconfirmed', 'Playing', 'Not Playing']

Games = new Meteor.Collection 'games'
# { team_id: 123,
#   date: '27-11-2012', time: '8:40', location: 'Brunswick',
#   players: {player_id: state} }


## FIXME: use date library
days_of_week = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
# returns the next 'day' Day after date.
get_day_after = (day, date = new Date()) ->
  difference = (day - date.getDay() + 7) % 7
  (new Date(date)).setDate(date.getDate() + difference)
