#!/bin/sh

kill -s 9 `ps -ef | grep "iperf -s" | grep -v grep | awk '{print $2}'`
