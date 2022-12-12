#!/bin/bash
PATH=/usr/bin:/opt/ros/galactic/bin\
 LD_LIBRARY_PATH=/opt/ros/galactic/lib\
 fastdds discovery -i 0 -l 127.0.0.1 -p 11811
exit 0
