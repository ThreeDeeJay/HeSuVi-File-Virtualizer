# HeSuVi File Virtualizer
Script that applies HeSuVi virtual surround to 7.1 input files.  
[Direct download](https://kutt.it/HFVDirectDownload)  
[Binaural audio in a nutshell](https://kutt.it/binaural)

# Requirements
- [HeSuVi installed](https://sourceforge.net/p/hesuvi/wiki/Help/).
- Input sample rate needs to match HeSuVi HRIRs' (44100hz or 48000hz).

# Guide
- Drag and drop file onto the script then press Enter, and follow the instructions.
- To change settings (HRIRs/output format/bitrate/extra arguments), press Enter without providing input.  
  - Settings are saved to an INI file for future sessions.

# Notes:
- Extra WAV files in the script folder will be added as new tracks without applying extra virtualization, using filename without extension as label.  
- Only input file's main video track will be used, and copied without re-encoding.  
- Only input file's main audio track will be used, re-encoded only if required (MP4).  
- While processing, HeSuVi will be turned on and cycle through HRIRs, which also applies to system audio.  

# Usage:
You can use this script to:
- Add a pre-virtualized 7.1 track to a movie to watch on a portable device or on the go.
- Compare surround virtualization software:
  - [Audio](https://airtable.com/shrTudzDGTsVR7p7p/tbloLjoZKWJDnLtTc) ([Airtable](https://airtable.com/)) Recommended .OGG/OPUS audio format (Opus codec) and 128k bitrate.  
  - [Video](https://share.vidyard.com/watch/RNK9HAzbAhD9funBsp6Emt?) ([Vidyard](https://www.vidyard.com/)) [Requires](https://knowledge.vidyard.com/hc/en-us/articles/360009999993-Videos-with-multiple-audio-tracks) .MP4 container, .M4A (AAC-LC) audio codec and H.264 video track. Also, avoid HRIRs with special characters like ssc_hù.wav.

# Contact
For more updates, troubleshooting or contribution, join the discussion at the [3D Game Audio Discord server](https://kutt.it/U3DAMChat).  

# Credits:  
[Matt Gore](https://sourceforge.net/u/jak33/profile/), [Jaakko Pasanen](https://sourceforge.net/u/jaakkopasanen/profile/) - [HeSuVi](https://sourceforge.net/projects/hesuvi/)  
[FFmpeg team](https://ffmpeg.org/developer.html) - [FFmpeg](https://ffmpeg.org/)  
[dbohdan](https://github.com/dbohdan) - [initool](https://github.com/dbohdan/initool)  
[Chris Bagwell](https://sourceforge.net/u/cbagwell/profile/) - [SoX](http://sox.sourceforge.net/)  
