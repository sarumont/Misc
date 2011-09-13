#!/bin/sh

print_usage() {
	echo "Usage: encode.sh -N <full name> [-n] [-t <track]"
	echo "  -N specifies the name of the movie"
	echo "  -n uses dvdnav:// rather than dvd://"
	echo "  -t specifies a track other than 1"
	exit 1
}

drive="cd0"
proto="dvd://"
track=1
while getopts N:nt: o
do
    case "$o" in
        N) fullname=$OPTARG;;
        n) proto="dvdnav://";;
        t) track=$OPTARG;;
        [?]) print_usage
    esac
done

if test -z "$fullname"; then
	print_usage
fi

name=`echo $fullname | sed -e 's/ /_/g'`
echo "Ripping $fullname"
mkdir $name

# rip it
mplayer -dumpstream -dumpfile $name/movie.vob ${proto}${track}//dev/${drive}

# grab the chapters
dvdxchap -t ${track} /dev/${drive} > $name/chapters.txt

# grab the info file for subtitles
mkdir $name/mount
mount_cd9660 /dev/${drive} $name/mount
cp $name/mount/video_ts/vts_01_0.ifo $name
umount $name/mount

# extract subtitle track 0
tccat -i /dev/${drive} -T ${track},-1 | tcextract -x ps1 -t vob -a 0x20 > $name/subs-0
subtitle2vobsub -o $name/$name -i $name/vts_01_0.ifo -a 0 < $name/subs-0

# rip audio track
mplayer -aid 128 $name/movie.vob -dumpaudio -dumpfile $name/audio_128.ac3

echo -e "\nRipping complete - please verify file and extract encoding parameters"
echo -e "Detect crop parameters with: mplayer -vf cropdetect $name/movie.vob -sb 50000000\n"
