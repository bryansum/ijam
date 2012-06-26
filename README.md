# iJam

*A collaborative music application for the iPhone.*

### [github.com/bryansum/iJam](http://github.com/bryansum/ijam)


iJam is a collaborative synthesizer for the iPhone, allowing for ad-hoc musical "sessions." Users can play either play an instrument in isolation or multiple players can play simultaneously. Either way, all music played is heard by all other members. It features multiple instruments via simple touch interfaces, and may optionally include gesture-input mechanisms (accelerometer, etc). iJam makes it effortless to do spontaneous musical collaboration with others.

To begin, a player can either create a new session or join an existing one. Using Apple Bonjour service, it's straightforward to determine who's located nearby. Sessions can be configured to be Wifi-based or Bluetooth-based, with both using Apple's Bonjour service to broadcast their presence.

<figure>
<img src="/images/ij-main.png" alt="Figure 1: iJam main application screen" />
<figcaption>Figure 1: iJam main application screen</figcaption>
</figure>

From here, the user can select from (currently) a few instruments, including `drumelectro`, `rhodeybass`, and `metronome`. These are synthesized using Miller Puckette's great [Pure Data](http://crca.ucsd.edu/~msp/software.html) synthesizer. iJam uses a port to iPhone, [pdlib](http://github.com/pdlib.html).

iJam can currently be used in two different "modes": *sequenced* or *free-form*. The two modes can be toggled by selecting the red record button on the options pane for the instrument. When in *sequenced* mode, all notes played are recorded on the timeline and played back on all future iterations of the loop unless the timeline is cleared.

Currently iJam requires a server with Ross Bencina's [oscgroups](http://www.audiomulch.com/~rossb/code/oscgroups/) server software to be running on a local machine, but this will be integrated into the host iPhone in the future (this allows for completely serverless session creation). Once connected, clients use UDP multicasting to send [OSC](http://opensoundcontrol.org/) messages directly to other session participants.

<figure>
<img src="/images/ij-drums.png" alt="Figure 2: iJam simplistic 'drumelectro' interface. Drums are movable. Note the timeline above." />
<figcaption>Figure 2: iJam 'drumelectro' interface. Drums are movable. Note the timeline above.</figcaption>
</figure>

I worked on this as part of a senior project at the University of Michigan.

