#!/usr/bin/env python

import socket
import json
from bottle import auth_basic, route, run, request, post
from collections import OrderedDict
import time

SOCKET_PATH = "/usr/local/nagios/var/rw/live"

def tablize(data):
        if not data:
                return []
        ret = []
        header = data[0]
        records = data[1:]
        for line in records:
                item = OrderedDict(zip(header, line))
                ret.append(item)
        return ret

def mklive(action, options):
        # Connect to Unix Socket
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(SOCKET_PATH)

        request = "GET %s\n" % action

        for k in options:
                for v in options.getall(k):
                        request += "%s: %s\n" % (k, v)  

        request += "OutputFormat: json\nColumnHeaders: on\n"
        print request
        s.send(request)

        # Important: Close sending direction. That way
        # the other side knows we are finished.
        s.shutdown(socket.SHUT_WR)

        # Read the answer
        answer = s.makefile().read()
        print answer
        data = json.loads(answer)
        return tablize(data)

def send_command(command):
        ts = time.time()
        line = "COMMAND [%d] %s\n" % (ts, command)

        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(SOCKET_PATH)
        s.send(line)
        s.close()

@route('/<action>')
def index(action):
        data = mklive(action, request.query)
        return {"data": data}

@route('/text/<action>')
def text(action):
        data = mklive(action, request.query)
        if not data:
                return ""

        out = ""
        header = data[0].keys()

        out += "    ".join(header) + "\n"
        for record in data:
                out += "    ".join(str(record[c]) for c in header) + "\n"
        return out


@post('/command')
def command():
    action = request.forms.get('action')
    send_command(action)
    return 'sent command'

run(host='10.1.1.100', port=8080)
