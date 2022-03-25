#!/bin/bash
nohup python3 -m uvicorn --app-dir ./code main:app --host 0.0.0.0 --port 8080 > /code/output.log & ovpn_run