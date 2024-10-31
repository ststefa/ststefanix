#!/bin/bash
# $Id: ststefa 2023-02-01 $
#set -x
# Mux an OBS recording + screen recording into a single h265 file

validate_names() {
    if ! [ -f "${1}.${2}" ] ; then
        echo "Main recording \"${1}.${2}\" not found" >&2
        return 1
    fi
    if [[ ${2} != mp4 ]] ; then
        echo "Can only mux mp4 files, not \"${2}\"" >&2
        return 1
    fi
    if ! [ -f "${1}-window.${2}" ] ; then
        echo "Window recording \"${1}-window.${2}\" missing" >&2
        return 1
    fi
}

mux () {
    FILE=${1%.*}
    EXT=${1##*.}
    validate_names "${FILE}" "${EXT}" || return 1

    # ${FILE}.${EXT} has 3 audio tracks: me=0, them=1, effects=2. Check that OBS extended audio settings match!
    # Remux to a "voices" stereo channel and an additional "effects" channel (just to keep it).
    # ${FILE}-window.${EXT} does not have any audio.
    # Do **not** mux all three into a single channel because MacOS Finder does not recognize that "2.1" audio as proper file (e.g. does not work with quicklook)
    # Re-encode video with x265 (hevc) because it gives a _much_ smaller result.
    # Use the shorter of the inputs (should be same length though)

    #ffmpeg -hide_banner -i "${FILE}.${EXT}" -i "${FILE}-window.${EXT}" -shortest -filter_complex "[0:a:0][0:a:1]amerge=inputs=2[voices],[0:a:2]acopy[effects]" -map 1:v -map [voices] -map [effects] -codec:v libx265 -vtag hvc1 "${FILE}.hevc.${EXT}"

    # 2023-10-23 Add echo reduction (agate+aformat) in "me". Probably only required due to wrong OBS audio settings. But does not hurt either
    ffmpeg -hide_banner -i "${FILE}.${EXT}" -i "${FILE}-window.${EXT}" -shortest -filter_complex "[0:a:0]agate[me],[me]aformat=channel_layouts=stereo[me2],[me2][0:a:1]amerge=inputs=2[voices],[0:a:2]acopy[effects]" -map 1:v -map [voices] -map [effects] -codec:v libx265 -vtag hvc1 "${FILE}.hevc.${EXT}"
}

case "$1" in
    -h|--help|"")
        echo "Mux OBS recording <mp4-filename>.<ext> and screen recording (<mp4-filename>-window.<ext>) into highly optimized h265 <mp4-filename>.hevc.mp4 Requires OBS setup as specified in script comments."
        echo "Usage: ${0} <mp4-filename>.<ext>"
        exit 1
        ;;
    *)
        if mux "$@" ; then
            echo "${FILE}.hevc.mp4 created."
        else
            false
        fi
esac
