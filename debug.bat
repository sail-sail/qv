@echo off
%~d0
cd %~dp0
node "--debug=5856" "util/index.js" "{debug:true}"
