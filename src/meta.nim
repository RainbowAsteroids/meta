from parseutils import parseInt
import parseopt
import tables
import private/taglib as tl

proc parse(s: string): uint =
    var res: int
    try:
        discard parseInt(s, res)
        if res < 0:
            raise ValueError.newException("")
    except ValueError:
        echo "Invalid number: ", s
        quit()

    res.uint

proc confirmChanges(): bool =
    while true:
        stdout.write("Would you like to write these changes to the song? ")

        let choice = stdin.readLine()

        if choice != "":
            if choice[0] in {'y', 'Y'}:
                return true
            if choice[0] in {'n', 'N'}:
                return false
            
        echo "I didn't understand what you meant."

type
    AttributeEnum = enum
        aeTrack, aeTitle, aeArtist, aeAlbum, aeGenre, aeYear, aeComment

    Command = object
        read: bool
        value: string
        case attribute: AttributeEnum
        of aeTrack, aeYear: number: uint
        else: discard

let attributeTable = {
    "track": aeTrack,
    "title": aeTitle,
    "artist": aeArtist,
    "album": aeAlbum,
    "genre": aeGenre,
    "year": aeYear,
    "comment": aeComment
}.toTable

const usage = "meta [options] <file>"
const version = "meta v1.0.2" 
const helpText = version & '\n' & usage & """
---------------------------------------------
-h, --help : this text
-v, --version : display the version and quit

-c, --confirm : confirm changes before making

Read the docs for more info about the following options: 
--track=[val] : change the track number, must be a positive integer
--title=[val] : change the song title
--artist=[val] : change the song artist
--album=[val] : change the song album
--genre=[val] : change the song genre
--year=[val] : change the song year, must be a positive integer
--comment=[val] : change the comment

--clear <attr> : clear the attribute attr. must be one of track, title, artist,
                 album, genre, year, or comment
"""

var filename: string
var commands = newSeq[Command]()
var finalRead = true
var confirm = false

var p = initOptParser(shortNoVal = {'h', 'v', 'c'}, 
                      longNoVal = @["track", "title", "artist", "album", 
                                    "genre", "year", "comment", "help", 
                                    "version", "confirm"])

for kind, key, val in p.getOpt():
    case kind:
        of cmdArgument:
            filename = key
        of cmdShortOption, cmdLongOption:
            case key:
                of "v", "version":
                    echo version
                    quit()

                of "c", "confirm":
                    confirm = true

                of "track", "title", "artist", "album", "genre", "year", "comment":
                    if val == "":
                        commands.add(Command(attribute: attributeTable[key], 
                                             read: true))
                        finalRead = false
                    
                    elif key == "track":
                        commands.add(Command(attribute: aeTrack, number: val.parse()))
                    
                    elif key == "year":
                        commands.add(Command(attribute: aeYear, number: val.parse()))

                    else:
                        commands.add(Command(attribute: attributeTable[key],
                                             value: val))

                of "clear":
                    if val notin attributeTable:
                        echo val, " is not a valid attribute!"
                        quit()
                    commands.add(Command(attribute: attributeTable[val],
                                         value: ""))

                else:
                    if key != "h" and key != "help":
                        echo "Unreconized option: ", key
                    echo helpText
                    quit()

        else:
            discard

if filename == "":
    echo "Missing file parameter. See meta --help for more info"
    quit()

var song = tl.open(filename)

# Write/Read commands
for command in commands:
    if not command.read:
        case command.attribute:
            of aeTrack:
                song.track = command.number
            of aeTitle:
                song.title = command.value
            of aeArtist:
                song.artist = command.value
            of aeAlbum:
                song.album = command.value
            of aeGenre:
                song.genre = command.value
            of aeYear:
                song.year = command.number
            of aeComment:
                song.comment = command.value

    else:
        case command.attribute:
            of aeTrack:
                echo song.track
            of aeTitle:
                echo song.title
            of aeArtist:
                echo song.artist
            of aeAlbum:
                echo song.album
            of aeGenre:
                echo song.genre
            of aeYear:
                echo song.year
            of aeComment:
                echo song.comment

if finalRead or confirm:
    echo "Track num: ", song.track
    echo "Title: ", song.title
    echo "Artist: ", song.artist
    echo "Album: ", song.album
    echo "Genre: ", song.genre
    echo "Year: ", song.year
    echo "Comment: ", song.comment

if (not confirm) or confirmChanges():
    song.save()

song.close()
