# meta
View and set the metadata for audio files

## Installation
First, get [choosenim](https://github.com/dom96/choosenim), then figure out
how to get taglib for your OS. Finally, run  
`nimble install https://github.com/RainbowAsteroids/meta`.

## Examples
Look at the metadata for a song
```
meta test.opus
```

Read a specific value for a song
```
meta example.mp3 --title
```

Modify a value for a song
```
meta song.flac --artist="me, lol" --album=portfolio
```

Clear out a specific value
```
meta from-ytdl.opus --clear comment
```

Learn more
```
meta --help
man meta # Linux only
```

## Usage
If you just want to view the metadata for a song, you can do `meta {song name}`.

### Commands
There are a few "command" options: `--track`, `--title`, `--artist`, `--album`,
`--genre`, `--year`, and `--comment`. These commands can be given values by
separating the values with an `=` sign.

If you want to view a specific value(s), you can add a "command" without any 
value.
The program will print out the value, in the order that you ask it to, 
separted by newlines. **Note**: `meta` does not filter or escape newlines
from the `--comment` field, so be wary when writing scripts.

If you want to set a value, you'd add a "command" and append a value to it.
`--track` and `--year` must be unsigned integers (a non-negative whole number).

You can clear a value with the `--clear` option and a command afterward 
(without the `--` prefix), like, so: `meta --clear title` would clear the title
value.
