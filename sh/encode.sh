#!/bin/sh

print_usage() {
	echo "Usage: encode.sh -N <full name> [-f] [-c]"
	echo "  -N specifies the name of the movie"
	echo "  -f FPS argument"
	echo "  -c Crop parameters"
	exit 1
}

fps=29.970
while getopts N:c:f: o
do
    case "$o" in
        N) fullname=$OPTARG;;
        c) crop=$OPTARG;;
        f) fps=$OPTARG;;
        [?]) print_usage
    esac
done

if test -z "$fullname"; then
	print_usage
fi

if test -z $crop; then
	print_usage
fi

name=`echo $fullname | sed -e 's/ /_/g'`
echo "Encoding $fullname"

#mencoder ${name}/movie.vob -vf pullup,softskip,crop=${crop},harddup -oac copy -ovc x264 -x264encopts subq=5:bframes=3:b_pyramid=normal:weight_b:turbo=1:threads=4:pass=1 -o /dev/null
mencoder ${name}/movie.vob -nosub -vf pullup,softskip,crop=${crop},harddup -oac copy -ovc x264 -x264encopts subq=5:bframes=3:b_pyramid=normal:weight_b:turbo=1:threads=4 -o $name/movie.264
mkvmerge --title "$fullname" -o $name/$name.mkv --chapters $name/chapters.txt --default-duration 0:29.970fps -A $name/movie.264 $name/audio_128.ac3

if ! test -d /video/movies/$name ; then
	mkdir -p /video/movies/$name
fi

mv $name/$name.* /video/movies/$name
