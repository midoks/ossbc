#!/bin/sh
gunicorn -k gevent -b :8004 ssbc.wsgi  --pid /tmp/debug_ssbc -w 1

