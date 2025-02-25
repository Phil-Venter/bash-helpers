#!/usr/bin/env bash

#==============================================================================
# Script Name: style.sh
#
# Description:
#   This script provides ANSI color and text effect utilities for styling
#   terminal output. It defines a set of predefined colors and effects,
#   allows mapping color names to their corresponding hex values, and enables
#   easy formatting of text with background and foreground colors as well as
#   various text effects like bold, underline, and blinking.
#
# Usage:
#   ./style.sh "Your formatted string here"
#
# Options:
#   This script does not take standard options but processes formatted input
#   using predefined placeholders for colors and effects.
#
# Notes:
#   - Colors and effects must be enclosed in curly braces with specific syntax.
#   - Supports both named colors and hex values.
#   - Multiple effects can be combined in a single expression.
#==============================================================================

#------------------------------------------------------------------------------
# Constants and Initial Variable Setup
#------------------------------------------------------------------------------

ERROR_PREFIX="\033[37;41;1m ERR \033[0m"

declare -Ar COLOURS=(
    ['aliceblue']='F0F8FF'       ['antiquewhite']='FAEBD7'      ['aqua']='00FFFF'                 ['aquamarine']='7FFFD4'
    ['azure']='F0FFFF'           ['beige']='F5F5DC'             ['bisque']='FFE4C4'               ['black']='000000'
    ['blanchedalmond']='FFEBCD'  ['blue']='0000FF'              ['blueviolet']='8A2BE2'           ['brown']='A52A2A'
    ['burlywood']='DEB887'       ['cadetblue']='5F9EA0'         ['chartreuse']='7FFF00'           ['chocolate']='D2691E'
    ['coral']='FF7F50'           ['cornflowerblue']='6495ED'    ['cornsilk']='FFF8DC'             ['crimson']='DC143C'
    ['cyan']='00FFFF'            ['darkblue']='00008B'          ['darkcyan']='008B8B'             ['darkgoldenrod']='B8860B'
    ['darkgray']='A9A9A9'        ['darkgrey']='A9A9A9'          ['darkgreen']='006400'            ['darkkhaki']='BDB76B'
    ['darkmagenta']='8B008B'     ['darkolivegreen']='556B2F'    ['darkorange']='FF8C00'           ['darkorchid']='9932CC'
    ['darkred']='8B0000'         ['darksalmon']='E9967A'        ['darkseagreen']='8FBC8F'         ['darkslateblue']='483D8B'
    ['darkslategray']='2F4F4F'   ['darkslategrey']='2F4F4F'     ['darkturquoise']='00CED1'        ['darkviolet']='9400D3'
    ['deeppink']='FF1493'        ['deepskyblue']='00BFFF'       ['dimgray']='696969'              ['dimgrey']='696969'
    ['dodgerblue']='1E90FF'      ['firebrick']='B22222'         ['floralwhite']='FFFAF0'          ['forestgreen']='228B22'
    ['fuchsia']='FF00FF'         ['gainsboro']='DCDCDC'         ['ghostwhite']='F8F8FF'           ['gold']='FFD700'
    ['goldenrod']='DAA520'       ['gray']='808080'              ['grey']='808080'                 ['green']='008000'
    ['greenyellow']='ADFF2F'     ['honeydew']='F0FFF0'          ['hotpink']='FF69B4'              ['indianred']='CD5C5C'
    ['indigo']='4B0082'          ['ivory']='FFFFF0'             ['khaki']='F0E68C'                ['lavender']='E6E6FA'
    ['lavenderblush']='FFF0F5'   ['lawngreen']='7CFC00'         ['lemonchiffon']='FFFACD'         ['lightblue']='ADD8E6'
    ['lightcoral']='F08080'      ['lightcyan']='E0FFFF'         ['lightgoldenrodyellow']='FAFAD2' ['lightgray']='D3D3D3'
    ['lightgrey']='D3D3D3'       ['lightgreen']='90EE90'        ['lightpink']='FFB6C1'            ['lightsalmon']='FFA07A'
    ['lightseagreen']='20B2AA'   ['lightskyblue']='87CEFA'      ['lightslategray']='778899'       ['lightslategrey']='778899'
    ['lightsteelblue']='B0C4DE'  ['lightyellow']='FFFFE0'       ['lime']='00FF00'                 ['limegreen']='32CD32'
    ['linen']='FAF0E6'           ['magenta']='FF00FF'           ['maroon']='800000'               ['mediumaquamarine']='66CDAA'
    ['mediumblue']='0000CD'      ['mediumorchid']='BA55D3'      ['mediumpurple']='9370DB'         ['mediumseagreen']='3CB371'
    ['mediumslateblue']='7B68EE' ['mediumspringgreen']='00FA9A' ['mediumturquoise']='48D1CC'      ['mediumvioletred']='C71585'
    ['midnightblue']='191970'    ['mintcream']='F5FFFA'         ['mistyrose']='FFE4E1'            ['moccasin']='FFE4B5'
    ['navajowhite']='FFDEAD'     ['navy']='000080'              ['oldlace']='FDF5E6'              ['olive']='808000'
    ['olivedrab']='6B8E23'       ['orange']='FFA500'            ['orangered']='FF4500'            ['orchid']='DA70D6'
    ['palegoldenrod']='EEE8AA'   ['palegreen']='98FB98'         ['paleturquoise']='AFEEEE'        ['palevioletred']='DB7093'
    ['papayawhip']='FFEFD5'      ['peachpuff']='FFDAB9'         ['peru']='CD853F'                 ['pink']='FFC0CB'
    ['plum']='DDA0DD'            ['powderblue']='B0E0E6'        ['purple']='800080'               ['rebeccapurple']='663399'
    ['red']='FF0000'             ['rosybrown']='BC8F8F'         ['royalblue']='4169E1'            ['saddlebrown']='8B4513'
    ['salmon']='FA8072'          ['sandybrown']='F4A460'        ['seagreen']='2E8B57'             ['seashell']='FFF5EE'
    ['sienna']='A0522D'          ['silver']='C0C0C0'            ['skyblue']='87CEEB'              ['slateblue']='6A5ACD'
    ['slategray']='708090'       ['slategrey']='708090'         ['snow']='FFFAFA'                 ['springgreen']='00FF7F'
    ['steelblue']='4682B4'       ['tan']='D2B48C'               ['teal']='008080'                 ['thistle']='D8BFD8'
    ['tomato']='FF6347'          ['turquoise']='40E0D0'         ['violet']='EE82EE'               ['wheat']='F5DEB3'
    ['white']='FFFFFF'           ['whitesmoke']='F5F5F5'        ['yellow']='FFFF00'               ['yellowgreen']='9ACD32'
)

declare -Ar EFFECTS=(
    # bold
    ['bold']=$'\033[1m'              ['reset-bold']=$'\033[22m'
    ['b']=$'\033[1m'                 ['rb']=$'\033[22m'
    # dim
    ['dim']=$'\033[2m'               ['reset-dim']=$'\033[22m'
    ['d']=$'\033[2m'                 ['rd']=$'\033[22m'
    # italic
    ['italic']=$'\033[3m'            ['reset-italic']=$'\033[23m'
    ['i']=$'\033[3m'                 ['ri']=$'\033[23m'
    # underline
    ['underline']=$'\033[4m'         ['reset-underline']=$'\033[24m'
    ['u']=$'\033[4m'                 ['ru']=$'\033[24m'
    # double-underline
    ['double-underline']=$'\033[21m' ['reset-double-underline']=$'\033[24m'
    ['du']=$'\033[21m'               ['rdu']=$'\033[24m'
    # curly-underline
    ['curly-underline']=$'\033[4:3m' ['reset-curly-underline']=$'\033[4:0m'
    ['cu']=$'\033[4:3m'              ['rcu']=$'\033[4:0m'
    # blink
    ['blink']=$'\033[5m'             ['reset-blink']=$'\033[25m'
    # reverse
    ['reverse']=$'\033[7m'           ['reset-reverse']=$'\033[27m'
    # hidden
    ['hidden']=$'\033[8m'            ['reset-hidden']=$'\033[28m'
    # strike-through
    ['strike-through']=$'\033[9m'    ['reset-strike-through']=$'\033[29m'
    ['s']=$'\033[9m'                 ['rs']=$'\033[29m'
    # overline
    ['overline']=$'\033[53m'         ['reset-overline']=$'\033[55m'
    ['o']=$'\033[53m'                ['ro']=$'\033[55m'
    # reset
    ['reset']=$'\033[0m'
)

#------------------------------------------------------------------------------
# Functions for Applying Colors and Text Effects
#------------------------------------------------------------------------------

colour() {
    local input="${3,,}"
    [[ -v COLOURS[$input] ]] && input="${COLOURS[$input]}"
    printf -v "$1" '\033[%d;2;%d;%d;%dm' "$2" "0x${input:0:2}" "0x${input:2:2}" "0x${input:4:2}"
}

effect() {
    [[ -v EFFECTS[$2] ]] && printf -v "$1" "%s" "${EFFECTS["${2,,}"]}"
}

#------------------------------------------------------------------------------
# Argument Validation
#------------------------------------------------------------------------------

if (( $# == 0 )); then
    echo -e "$ERROR_PREFIX this script requires a user defined pattern." >&2 ; exit 1
fi

#------------------------------------------------------------------------------
# Process Input String for Color and Effect Formatting
#------------------------------------------------------------------------------

LINE="$*"

# Process multi-part expressions enclosed in { }
while [[ $LINE =~ \{([^}]+;[^}]+)\} ]]; do
    REPLACEMENT=""
    IFS=';' read -ra PARTS <<< "${BASH_REMATCH[1]}"
    for PART in "${PARTS[@]}"; do REPLACEMENT+="{$PART}"; done
    LINE="${LINE//${BASH_REMATCH[0]}/$REPLACEMENT}"
done

# Process background color placeholders
while [[ $LINE =~ \{[[:space:]]*bg:([a-zA-Z0-9]+)[[:space:]]*\} ]]; do
    colour COLOR 48 "${BASH_REMATCH[1]}"
    LINE="${LINE//${BASH_REMATCH[0]}/$COLOR}"
done

# Process foreground color placeholders
while [[ $LINE =~ \{[[:space:]]*fg:([a-zA-Z0-9]+)[[:space:]]*\} ]]; do
    colour COLOR 38 "${BASH_REMATCH[1]}"
    LINE="${LINE//${BASH_REMATCH[0]}/$COLOR}"
done

# Process text effect placeholders
while [[ $LINE =~ \{[[:space:]]*fx:([a-zA-Z\-]+)[[:space:]]*\} ]]; do
    effect EFFECT "${BASH_REMATCH[1]}"
    LINE="${LINE//${BASH_REMATCH[0]}/$EFFECT}"
done

# Reset formatting placeholders
while [[ $LINE =~ \{[[:space:]]*reset[[:space:]]*\} ]]; do
    LINE="${LINE//${BASH_REMATCH[0]}/$'\033[0m'}"
done

#------------------------------------------------------------------------------
# Print Formatted Output
#------------------------------------------------------------------------------

printf "%s\033[0m" "${LINE//m\\033[/;}"
