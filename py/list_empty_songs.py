#!/usr/bin/env python
from gmusicapi import Mobileclient
import sys
import io
import os

api = Mobileclient()
logged_in = api.login('sarumont@gmail.com', os.environ['PASSWORD'], Mobileclient.FROM_MAC_ADDRESS)
if logged_in:
    print "Logged in successfully"
else:
    print "Error logging in"
    sys.exit(1)

delete = os.getenv('DELETE_BAD_SONGS', False)

bad_ids = []
with io.open('/tmp/zero_length.csv', 'w') as csv:
    csv.write(u"Artist,Album,Title\n")
    library = api.get_all_songs()
    for track in library:
        millis = int(track['durationMillis'])
        if millis < 1000:
            line = u"{albumArtist:s},{album:s},{title:s}\n".format(**track)
            csv.write(line)
            bad_ids.append(track['id'])

print "Found %d bad songs" % len(bad_ids)
if delete:
    print "Deleting bad songs"
    api.delete_songs(bad_ids)

api.logout()
