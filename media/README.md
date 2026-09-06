# media

Three files with no readable source. There is nothing to edit here and nothing
to run: the point of each of them is what it looks like, so each opens rendered
rather than as text.

| file | what it is for |
|---|---|
| `demo.mp4` | a video the system decodes natively: the tab shows its first frame, paused, with the transport controls. Switching to another tab pauses it, and coming back does not start it again |
| `capture.webm` | the same three seconds in a container the system will not decode. This one is *meant* to fall back — the binary notice, with its Quick Look button — and an editor that played it would mean the fallback had stopped being tested |
| `frame.png` | the first frame on its own, for the plainest case there is: a picture opens as a picture |

The pattern is a frame counter, which is the only thing that makes a paused
video and a playing one tell themselves apart in a screenshot.

They are committed rather than generated: 60 KB between them, against ffmpeg
being one more thing to have installed. Remaking them is three commands, and
the sizes below are what keep them worth committing.

```sh
ffmpeg -f lavfi -i "testsrc2=size=320x180:rate=12:duration=3" \
	-c:v libx264 -pix_fmt yuv420p -crf 34 -movflags +faststart demo.mp4
ffmpeg -f lavfi -i "testsrc2=size=320x180:rate=12:duration=3" \
	-c:v libvpx-vp9 -crf 55 -b:v 0 capture.webm
ffmpeg -i demo.mp4 -frames:v 1 -vf scale=320:180 frame.png
```
