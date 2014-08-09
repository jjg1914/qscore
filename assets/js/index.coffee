app = angular.module "app", [ "ngRoute" ]

class Goal
  constructor: (@team_id,@at) ->

app.factory "timer", ($interval) ->
  class Timer
    constructor: (@t = 0)->
      @_t = 0
      @_alarms = []

    start: ->
      unless @interval
        last = performance.now()
        @_interval = $interval =>
          now = performance.now()
          @_t += now - last
          last = now
          while @_alarms.length > 0 and @_alarms[0].countdown < @_t
            @_alarms[0].f()
            @_alarms[0].pop()
        , 50

    stop: ->
      if @_interval
        $interval.cancel @_interval
        delete @_interval

    reset: ->
      @_t = 0

    toggle: ->
      if @isRunning() then @stop() else @start()

    isRunning: ->
      @_interval?

    ellapsed: (countdown) ->
      if countdown?
        Math.max countdown - @_t, 0
      else
        @_t

    alarm: (countdown,f) ->
      alarm =
        countdown: countdown
        f: f
      for e,i in @_alarms
        if e.countdown > countdown
          @_alarms.splice i, 0, alarm
          return
      @_alarms.push alarm

app.filter "timerFormat", ->
  (value) ->
    value = Math.floor value / 100
    milli = value % 10
    value = Math.floor value / 10
    seconds = value % 60
    seconds = "0" + seconds if seconds < 10
    minutes = Math.floor value / 60
    minutes + ":" + seconds + ":" + milli

app.controller "AppController", ($scope,$timeout,timer) ->
  goals = []
  timeout = null

  $scope.timer = new timer

  $scope.details = -> goals.concat([]).reverse()

  $scope.goal = (team_id) ->
    if timeout?
      $timeout.cancel timeout
      timeout = null

      goals.push new Goal team_id, $scope.timer.ellapsed()


  $scope.ungoal = (team_id) ->
    unless timeout?
      timeout = $timeout ->
        timeout = null

        for goal,i in goals by -1
          if goal.team_id == team_id
            goals.splice i, 1
            break
      , 500

  $scope.score = (team_id) ->
    score = 0
    for goal in goals
      if goal.team_id == team_id
        score += 10
    return score
        
    
