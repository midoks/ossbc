#!/bin/sh
gunicorn -k gevent -b :8001 ssbc.wsgi -k gevent --pid /tmp/debug_ssbc -w 1

