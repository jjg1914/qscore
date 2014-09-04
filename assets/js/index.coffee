app = angular.module "app", [ "ngRoute" ]

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

app.directive "qPressBegin", ->
  restrict: "A"
  link: ($scope,$element,attributes) ->
    $element.on "mousedown touchstart", (e) ->
      $scope.$apply ->
        $scope.$eval attributes.qPressBegin
      e.preventDefault()

app.directive "qPressEnd", ->
  restrict: "A"
  link: ($scope,$element,attributes) ->
    $element.on "mouseup touchend", (e) ->
      $scope.$apply ->
        $scope.$eval attributes.qPressEnd
      e.preventDefault()

app.controller "AppController", ($scope,$timeout,timer) ->
  goals = []
  catches = []
  timeout = null

  $scope.period = "regular"

  $scope.timer = new timer

  $scope.floor = 18 * 60 * 1000

  $scope.newGame = ->
    $scope.period = "regular"
    $scope.timer = new timer
    $scope.floor = 18 * 60 * 1000
    delete $scope.overtime
    goals.length = 0
    catches.length = 0
    $scope.selected = -2

  $scope.details = ->
    catches.concat(goals).sort (a,b) ->
      if a.at < b.at
        1
      else if a.at > b.at
        -1
      else 0

  $scope.selected = -2

  $scope.goal = (team_id) ->
    if $scope.period != "game_over"
      goals.push
        team_id: team_id
        at: $scope.timer.ellapsed()
        type: "goal"
        name: "Goal"
      if $scope.period == "sudden_death"
        $scope.timer.stop() if $scope.timer.isRunning()
        $scope.selected += 2 unless $scope.selected >= 0
        $scope.period = "game_over"
        if $scope.score(0) > $scope.score(1)
          $scope.selected = 0
        else
          $scope.selected = 1

  $scope.ungoal = (team_id) ->
    if $scope.period != "game_over"
      for goal,i in goals by -1
        if goal.team_id == team_id
          goals.splice i, 1
          break

  $scope.catch = (team_id) ->
    if $scope.timer.ellapsed() >= $scope.floor and $scope.period != "game_over"
      catches.push
        team_id: team_id
        at: $scope.timer.ellapsed()
        type: "catch"
        name: "Catch"
      if $scope.score(0) == $scope.score(1)
        if $scope.period == "regular"
          $scope.period = "overtime"
          $scope.overtime = $scope.timer.ellapsed() + (5 * 60 * 1000)
          $scope.floor = $scope.timer.ellapsed() + (30 * 1000)
        else if $scope.period = "overtime"
          $scope.period = "sudden_death"
          delete $scope.overtime
          $scope.floor = $scope.timer.ellapsed() + (30 * 1000)
      else
        $scope.period = "game_over"
        delete $scope.overtime
        if $scope.score(0) > $scope.score(1)
          $scope.selected = 0
        else
          $scope.selected = 1

  $scope.scoreMouseup = (team_id) ->
    if timeout?
      $timeout.cancel timeout
      timeout = null
      $scope.goal(team_id)

  $scope.scoreMousedown = (team_id) ->
    if $scope.selected >= 0
      if $scope.period != "game_over"
        $scope.selected = team_id
    else unless timeout? or not $scope.timer.isRunning()
      timeout = $timeout ->
        timeout = null
        $scope.ungoal(team_id)
      , 500

  $scope.score = (team_id) ->
    score = 0
    score += 10 for goal in goals when goal.team_id == team_id
    score += 30 for c in catches when c.team_id == team_id
    return score

  $scope.timerMouseup = ->
    if timeout?
      $timeout.cancel timeout
      timeout = null
      if $scope.timer.isRunning()
        $scope.timer.stop()
        $scope.selected += 2 unless $scope.selected >= 0
      else if $scope.period != "game_over"
        $scope.timer.start()
        $scope.selected -= 2 unless $scope.selected < 0

  $scope.timerMousedown = ->
    unless timeout?
      timeout = $timeout ->
        timeout = null
        $scope.newGame()
      , 1000
