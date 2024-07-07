#!/bin/bash
setxkbmap -query | awk '/layout:/ {print toupper($2)}'

