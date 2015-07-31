_              = require "lodash"
async          = require "async"
moment         = require "moment"
request        = require "request"
eveonlinejs    = require "eveonlinejs"


# Configs
eveonlinejs.setParams
  keyID: process.env.EVE_API_KEY
  vCode: process.env.EVE_API_CODE
refTypeID =
  "97": "planet_export"
  "96": "planet_import"

# Index route
exports.index = (req, res) ->
  query_journal {}, null, null, (err, data) ->
    return res.json err if err?
    puppet_list = []
    for puppet, planets of data
      planet_counter = 0
      planet_sum = 0
      for planet, days of planets
        day_counter = 0
        for day_key, day of days
          if day.planet_export?.length > 0 or day.planet_import?.length > 0
            day_counter++
        planet_counter++
        planet_sum += day_counter
      puppet_list.push
        name: puppet
        planet_count: planet_counter
        avg_activity: planet_sum / planet_counter
    res.json _.sortBy puppet_list, "avg_activity"

query_journal = (res, first, last, cb) ->
  args =
    corporationID: "685333984"
    accountKey: "1000"
    rowCount: "2560"
  args.fromID = last.refID if last?

  eveonlinejs.fetch "corp:WalletJournal", args, (err, data) ->
    return cb err if err?
    counter = 0
    for refID, entry of data.entries
      counter++
      if not first? or moment(first.date) < moment(entry.date)
        first = entry
      if not last? or moment(last.date) > moment(entry.date)
        last = entry
      if entry.refTypeID is "97" or entry.refTypeID is "96"
        deep_push res, [entry.ownerName1, entry.argName1, moment(entry.date).format("YYYY-MM-DD"), refTypeID[entry.refTypeID]], entry
    return cb null, res if counter < 2500
    query_journal res, first, last, cb

deep_push = (obj, key, val) ->
  arr = _.get obj, key, []
  arr.push val
  _.set obj, key, arr
