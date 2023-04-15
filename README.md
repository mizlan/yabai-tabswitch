# yabai-tabswitch

Requires [luvit](https://luvit.io/), [yabai](https://github.com/koekeishiya/yabai), and preferably [skhd](https://github.com/koekeishiya/skhd).
I also use [abduco](https://github.com/martanne/abduco) to have my server run
detached from any terminal.

Example skhd config:

```
cmd + shift - return : echo 'gFirefox' | nc 127.0.0.1 1337
cmd + shift - e : echo 'gkitty' | nc 127.0.0.1 1337
cmd + shift - p : echo 'gsioyek' | nc 127.0.0.1 1337
cmd + shift - j : echo 'c' | nc 127.0.0.1 1337
cmd + shift - m : echo 'r' | nc 127.0.0.1 1337
```

- `r` forces the server to update its knowledge of open windows and their information
- `gAPPNAME` instantly jumps to an instance of that app
- `c` cycles between open instances of the same application
