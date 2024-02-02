This repository creates and distributes the unofficial Appimage of Hypnotix.

### NOTE: this is still an EXPERIMENTAL BUILD, don't use it daily. It is not ready yet!

---------------------------------

# Known issue
- After 1-2 times you change the channel, it crashes with the following message:
```
[xcb] Unknown sequence number while processing queue
[xcb] You called XInitThreads, this is not your fault
[xcb] Aborting, sorry about that.
xcb_io.c:278: poll_for_event: Assertion `!xcb_xlib_threads_sequence_lost' failed.
```
also
```
libEGL warning: DRI2: failed to authenticate
```
and this happens with both versions, the one based on .deb packages and the one based on JuNust (Arch Linux).
