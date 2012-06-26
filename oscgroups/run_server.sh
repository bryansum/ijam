#!/bin/sh
# a simple script to run the server in the background
# nohup means that the server will keep running when you log out
# you will need to use the ps and kill commands to find and kill
# the server if you need to
# a better solution is the OscGroupServerStartStop script
nohup ./bin/OscGroupServer &
