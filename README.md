# easyTH

### What is it?
easyTH is an add-on for FFXI's third-party loader and hook Ashita (https://www.ashitaxi.com/).
The purpose of this add-on is to offer easy tracking for Treasure Hunter procs.
<br></br>

### How does it work?
This add-on uses ImGui to create a window that display the relevant information.
<br></br>

### Main features
When on ${\textsf{\color{lime}{THF}}}$ (or ${\textsf{\color{orange}{any job}}}$ using the appropriate command), the addon tracks the TH procs applied by any THF in the party.
The addon displays information in a minimal, non-intrusive window that can be repositioned by dragging it with the mouse.
By default, the window remains hidden and only appears when there is a chance to detect TH procs.

### Why is it different?
Many Treasure Hunter procs trackers are text-based, meaning they parse the game chat looking for key words to display the necessary information.
easyTH is packet-based, efficiently filtering packets to only process those that contain the proc information.
The advantage of a packet-based approach is solid reliability when collecting the information and displaying them, which is often an issue on text-based trackers.

### Installation
Go over the <a href="https://github.com/ariel-logos/easyTH/releases" target="_blank">Releases</a> page, download the latest version and unpack it in the add-on folder in your Ashita installation folder. You should now have among the other add-on folders the "easyTH" one!
<br></br>

### Compatibility Issues
No compatibility issues found so far.

#### Commands
```/addon load easyTH``` Loads the add-on in Ashita.

```/addon unload easyTH``` Unloads the add-on from Ashita.

```/easyth anyjob``` Toggles the tracking between "only on THF main job" and "any job".

<br></br>

### Credits
easyTH relies on the following scripts developed the Ashita Development Team
<ul>
  <li>bitreader.lua</li>
  <li>parser.lua</li>
</ul>

Ashita Development Team contacts:
<ul>
<li><a href="https://www.ashitaxi.com" target="_blank">Website</a></li>
<li><a href="https://discord.gg/Ashita" target="_blank">Discord</a></li>
</ul>
