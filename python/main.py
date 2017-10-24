#!/usr/bin/env python
from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.response import Response
import requests

def home(request):
    target  = request.params.get(u'target', None)
    keyword = request.params.get(u'keyword', None)
    found = u'false'
    print target, keyword
    if target and keyword:
        resp = requests.get(target, allow_redirects=True)
        if keyword in resp.text:
            found = u'true'
    return Response(found)

if __name__ == '__main__':
    with Configurator() as config:
        config.add_route('home', '/')
        config.add_view(home, route_name='home')
        app = config.make_wsgi_app()
    server = make_server('0.0.0.0', 8888, app)
    print("listening on 0.0.0.0:8888")
    server.serve_forever()
