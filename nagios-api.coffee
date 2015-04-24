# Description:
#   Messing around with info
#
# Configuration:
#   NAGIOS_BASE_URL
# Commands:
#   hubot nagios <arg> - Query Nagios
#   hubot nagios {critical,warning,unknown}-services - Print services of given state
#   hubot nagios hosts-down              - Print hosts that are in DOWN or UNREACHABLE state
#   hubot nagios modified                - Print hosts that have been modified via WUI"
#   hubot nagios contacts                - Print list of available contacts
#   hubot nagios contactgroups           - Print contactgroups and their members
#   hubot nagios timeperiods             - Print list of available timeperiods
#   hubot nagios hostinfo <name>         - Print information about host
#   hubot nagios hostgroups              - Print list of hostgroups
#   hubot nagios hostgroupinfo <name>    - Print hostgroup member list
#   hubot nagios servicegroups           - Print list of servicegroups
#   hubot nagios servicegroupinfo <name> - Print servicegroup information
#   hubot nagios commandinfo <name>      - Print command
#   hubot nagios downtimes               - Print host or service in downtime
#   hubot nagios command <command>       - Execute external command 

QS = require "querystring"

module.exports = (robot) ->
  nagios_base_url = process.env.NAGIOS_BASE_URL + "text/"
  nagios_command_url = process.env.NAGIOS_BASE_URL + "command"

  robot.hear /nagios critical-services/, (msg) ->
    send_request(msg, nagios_base_url + "services?Columns=host_name+description&Filter=state+%3d+2")

  robot.hear /nagios warning-services/, (msg) ->
    send_request(msg, nagios_base_url + "services?Columns=host_name+description&Filter=state+%3d+1")

  robot.hear /nagios unknown-services/, (msg) ->
    send_request(msg, nagios_base_url + "services?Columns=host_name+description&Filter=state+%3d+3")

  robot.hear /nagios hosts-down/, (msg) ->
    send_request(msg, nagios_base_url + "hosts?Columns=host_name+address&Filter=state+%21%3d+0")

  robot.hear /nagios modified/, (msg) ->
    send_request(msg, nagios_base_url + "hosts?Columns=host_name+modified_attributes_list&Filter=modified_attributes_list+%21%3d+0")

  robot.hear /nagios hostinfo (.*)/, (msg) ->
    arg = msg.match[1]
    send_request(msg, nagios_base_url + "hosts?Columns=name+address+check_command+contacts+contact_groups+downtimes+next_check+num_services_crit+num_services_ok&Filter=name+%3d+" + arg)

  robot.hear /nagios hostgroups/, (msg) ->
    send_request(msg, nagios_base_url + "hostgroups?Columns=name")

  robot.hear /nagios servicegroups/, (msg) ->
    send_request(msg, nagios_base_url + "servicegroups?Columns=name")

  robot.hear /nagios hostgroupinfo (.*)/, (msg) ->
    arg = msg.match[1]
    send_request(msg, nagios_base_url + "hostgroups?Columns=name+members&Filter=name+%3d+" + arg)

  robot.hear /nagios servicegroupinfo (.*)/, (msg) ->
    arg = msg.match[1]
    send_request(msg, nagios_base_url + "servicegroups?Columns=num_services+num_services_crit+num_services_warn+num_services_ok+num_services_unknown+num_services_pending&Filter=name+%3d+" + arg)

  robot.hear /nagios contacts/, (msg) ->
    send_request(msg, nagios_base_url + "contacts?Columns=name+email+pager")
  
  robot.hear /nagios contactgroups/, (msg) ->
    send_request(msg, nagios_base_url + "contactgroups")

  robot.hear /nagios timeperiods/, (msg) ->
    send_request(msg, nagios_base_url + "timeperiods")

  robot.hear /nagios commandinfo (.*)/, (msg) ->
    arg = msg.match[1]
    send_request(msg, nagios_base_url + "commands?Filter=name+%3d+" + arg)

  robot.hear /nagios downtimes/, (msg) ->
    send_request(msg, nagios_base_url + "services?Filter=scheduled_downtime_depth+%21%3d+0&Filter=host_scheduled_downtime_depth+%21%3d+0" + arg)

  robot.hear /nagios command (.*)/, (msg) ->
    action = msg.match[1]
    send_command(msg, action)

  send_request = (msg, url) ->
    robot.http(url)
      .get() (err, res, body) ->
        if (res.statusCode == 200)
          msg.send if body == "" then "Empty Result" else body
        else
          msg.send "Error talking to nagios"

  send_command = (msg, action) ->
    data = QS.stringify action: action
    robot.http(nagios_command_url)
      .post(data) (err, res, body) ->
        if (res.statusCode == 200)
          msg.send if body == "" then "Empty Result" else body
        else
          msg.send "Error talking to nagios"
