#!/bin/sh
# vim: set filetype=tcl :
# \
exec /usr/local/bin/tclsh "$0" ${1+"$@"}

package require http

set conf(BASE) "/tank/misc/mpd/OCR/latest"

# Returns a random integer
proc random {{ range 100 }} {
	return [expr {int( rand() * $range ) }]
}

# returns the body of a URL
proc http_fetch { url } {

    set connection [::http::geturl $url -blocksize 4096]

    upvar #0 $connection state

	# check for redirection
    set status_line $state(http)
	set parts [split $status_line  ]
	set status [lindex $parts 1]
	if { $status >= 300 && $status < 400 } {
		array set meta $state(meta)
		set url $meta(Location)
		set connection [::http::geturl $url -blocksize 4096]
		upvar #0 $connection state
	}
    set body $state(body)

    ::http::cleanup $connection
    return $body 

}

# Downloads a file, found at url, to the local file named fn
proc http_download_file { url fn } { 
    set connection [::http::geturl $url -channel [open $fn w]]
    ::http::cleanup $connection
}

proc urlDecode { txt } {
   # Replace `+' chars, then hexidecimals
   regsub -all { \+ } $txt { } txt
   regsub -all {%([0-9a-hA-H][0-9a-hA-H])} \
      $txt {[format %c 0x\1]} url
   # Send back the result
   return [subst $url]
}

# extracts the links from the RSS XML
proc extract_links { rss } {

    foreach line [split $rss \n] {
        if { [regexp {.*link.*} $line] } {
            if { [regexp {org<} $line] } {
                continue
            }

            regsub -all {.*>(http.*)<.*} $line {\1} line
            lappend links $line
        }

    }
	if { ! [info exists links] } {
		puts "No links found in RSS:\n$rss"
		exit 1
	}
    return $links

}

# extracts a download link from an HTML page
proc extract_download_link { html } {

    foreach line [split $html \n] {
        if { [regexp {.*Download from.*} $line] } {
            regsub -all {.*(http.*)\".*} $line {\1} line
            lappend links $line
        }
    }

	if { ! [info exists links] } {
		puts "No links found in HTML:\n$html"
		exit 1
	}
    return [lindex $links [random [llength $links]]]
}

########################################
# MAIN
########################################
set remixes [extract_links [http_fetch "http://ocremix.org/feeds/ten20/"]]
foreach remix $remixes {

    set link [extract_download_link [http_fetch $remix]]
    set parts [split $link /]
    set fn [urlDecode [lindex $parts end]]
    set path "$conf(BASE)/$fn"

    if { ! [file exists $path] } {
        puts -nonewline "Downloading $fn..."
        http_download_file $link $path
        puts "OK"
    }

}
