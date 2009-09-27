-module(out).
-export([m/0]).
m()->io:write(pong).