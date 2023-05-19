# yabai-tabswitch

Requires [luvit](https://luvit.io/),
[yabai](https://github.com/koekeishiya/yabai), and preferably
[skhd](https://github.com/koekeishiya/skhd) (you may also use
[Hammerspoon](https://github.com/Hammerspoon/hammerspoon)).
I also use [abduco](https://github.com/martanne/abduco) to have my server run
detached from any controlling terminal.

Example skhd config:

```
# when keybind is pressed, cycle if already in the corresponding application,
# otherwise jump to an instance of that application

cmd + shift - return [
  "firefox" : echo 'c'        | nc 127.0.0.1 1337
  *         : echo 'gFirefox' | nc 127.0.0.1 1337
]

cmd + shift - e [
  "kitty" : echo 'c'      | nc 127.0.0.1 1337
  *       : echo 'gkitty' | nc 127.0.0.1 1337
]

cmd + shift - p [
  "Skim" : echo 'c'     | nc 127.0.0.1 1337
  *      : echo 'gSkim' | nc 127.0.0.1 1337
]

cmd + shift - b : echo 'gYomu' | nc 127.0.0.1 1337

# cycle
cmd + shift - j : echo 'c' | nc 127.0.0.1 1337

# refresh internal knowledge of open applications
cmd + shift - m : echo 'r' | nc 127.0.0.1 1337

# fix the current instance of an application as its first jumped-to instance
cmd + shift - k : echo 'x' | nc 127.0.0.1 1337

```

- `r` forces the server to update its knowledge of open windows and their
  information
- `gAPPNAME` instantly jumps to an instance of that app
- `c` cycles between open instances of the same application
- `x` fixes the current open instance as the first one to be jumped to on a
  later invocation
