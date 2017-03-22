fs = require "fs"
execFn = ->
  #初始化城市
  cityArr = require "./city"
  fs.writeFileSync __dirname+"/city.sql",""
  for eny,i in cityArr
    str = "insert into provin(id,lbl) values(#{i+1},'#{eny.name}');\n"
    fs.appendFileSync __dirname+"/city.sql",str
    for eny1,j in eny.city
      str = "insert into city(provin_id,lbl) values(#{i+1},'#{eny1.name}');\n"
      fs.appendFileSync __dirname+"/city.sql",str
    fs.appendFileSync __dirname+"/city.sql","\n"
  fs.appendFileSync __dirname+"/city.sql","select setval('provin_id_seq',(select max(id) from \"provin\"));"
  return
execFn()