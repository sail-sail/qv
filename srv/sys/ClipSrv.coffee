{SysSrv} = require "./SysSrv"
mqtt = require "mqtt"

clipSrv = undefined

PrnClzz = SysSrv
exports.ClipSrv = new Class
  Extends: PrnClzz
  initialize: (options) ->
    t = this
    return clipSrv if clipSrv
    PrnClzz.prototype.initialize.apply t,arguments
    clipSrv = t
    return
  onDraw: ->
    t = this
    o = t.options
    await PrnClzz.prototype.onDraw.apply t,arguments
    client  = mqtt.connect "mqtt://127.0.0.1:1883",{username:"system",password:"iub994d8"}
    client.on 'connect',->
      client.subscribe 'du3uvi9b'
      return
    client.on 'message',(topic, message)->
      if topic is "du3uvi9b"
        message = JSON.decode message.toString()
        return if !message
        await t.callSql {reqOpt_ibmkx5s8:true,sqlNotLog:true},"insert into mqt_clp(uid,tx) values($1,$2)",[message.uid,message.tx]
      return
    return