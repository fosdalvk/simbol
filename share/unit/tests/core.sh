# vim: tw=0:ts=4:sw=4:et:ft=bash

declare -g counter=2
function coreCacheTester() {
    local -i e

    local l_CACHE_SIG='cache-test'
    local -i l_CACHE_TTL=$1

    core:global g.counter ${counter}
    counter=$(core:global g.counter)
    case $2 in
        up)
          g_CACHE_OUT || {
            core:global g.counter $((counter+=100))
            e=$?
          } > ${g_CACHE_FILE?}; g_CACHE_IN; e=$?
        ;;
        down)
          g_CACHE_OUT || {
            core:global g.counter $((counter-=10))
            e=$?
          } > ${g_CACHE_FILE?}; g_CACHE_IN; e=$?
        ;;
        jump)
          g_CACHE_OUT || {
            core:global g.counter $((counter+=1000))
            e=$?
          } > ${g_CACHE_FILE?}; g_CACHE_IN; e=$?
        ;;
    esac

    counter=$(core:global g.counter)

    return $e
}

function testCoreUnsupportedAssociativeArrayAssignments() {
    local vetted
    vetted="$(md5sum <(git grep -E '[a-zA-Z0-9]+\+=\( *\['))"
    assertEquals '0.0.1' '09a2684a0023bdd670ad455efbd74d8e' "${vetted%% *}"
}

function testCoreGlobalArithmeticFailure() {
    core:global g.num 1024
    local -i v=$(core:global g.num)
    assertEquals "${FUNCNAME?}/1.1" 1024 $v

    core:global g.num += 'JOKER'
    assertFalse "${FUNCNAME?}/1.2" $?

    v=$(core:global g.num)
    assertEquals "${FUNCNAME?}/1.3" 1024 $v
}

function testCoreGlobalArithmeticSuccess() {
    core:global g.str 'BATMAN'

    core:global g.num 1024
    local -i v=0
    v=$(core:global g.num)
    assertTrue "${FUNCNAME?}/1.1" $?
    assertEquals "${FUNCNAME?}/1" 1024 $v

    core:global g.num += 1024
    v=$(core:global g.num)
    assertEquals "${FUNCNAME?}/1" 2048 $v
}

function testCoreGlobalAtomicity() {
    #. Generating subshells is easy...
    #.
    #.    function f() { cat; eval 'echo ${BASHPID}:${BASH_SUBSHELL}'; }
    #.
    #. Then call `f|(f|(f|f|)|f)` or something.  Here we use this to test
    #. atomicity.

    local -i v=2048
    core:global g.variable $v

    core:global g.variable += 512 | (
        core:global g.variable += 32
    )

    core:global g.variable += 8
    v=$(core:global g.variable)

    assertEquals "${FUNCNAME?}/1" 2600 $v
}

function testCoreMockEnv() {
    assertTrue "${FUNCNAME?}/0" '[ ${#SIMBOL_USER_MOCKENV} -gt 0 ]'
}

function testCoreMockWrite() {
    # Test creation of a mock context
    mock:write <<!
        declare -A BATMAN=( [k1]="0xDEADBEEF" )
!
    local -i size
    size=$(stat --printf '%s\n' "${SIMBOL_USER_MOCKENV?}.default")
    assertTrue "${FUNCNAME?}/2.1" '[ ${size} -gt 0 ]'
    grep -q 'BATMAN' "${SIMBOL_USER_MOCKENV?}.default"
    assertTrue "${FUNCNAME?}/2.2.1" $?
    grep -q 'JOKER' "${SIMBOL_USER_MOCKENV?}.default"
    assertFalse "${FUNCNAME?}/2.2.2" $?
    grep -q '0xDEADBEEF' "${SIMBOL_USER_MOCKENV?}.default"
    assertTrue "${FUNCNAME?}/2.2.3" $?
    size=$(cat "${SIMBOL_USER_MOCKENV?}.default"|wc -l)
    assertEquals "${FUNCNAME?}/2.2.4" 1 ${size}

    mock:write <<!
        declare -A JOKER=( [k1]="0xDEADBEEF" )
!
    size=$(stat --printf '%s\n' "${SIMBOL_USER_MOCKENV?}.default")
    assertTrue "${FUNCNAME?}/3.1" '[ ${size} -gt 0 ]'
    grep -q 'BATMAN' "${SIMBOL_USER_MOCKENV?}.default"
    assertTrue "${FUNCNAME?}/3.2.1" $?
    grep -q 'JOKER' "${SIMBOL_USER_MOCKENV?}.default"
    assertTrue "${FUNCNAME?}/3.2.2" $?
    grep -q '0xDEADBEEF' "${SIMBOL_USER_MOCKENV?}.default"
    assertTrue "${FUNCNAME?}/3.2.3" $?
    size=$(cat "${SIMBOL_USER_MOCKENV?}.default"|wc -l)
    assertEquals "${FUNCNAME?}/3.2.4" 2 ${size}

    mock:clear
}

function testCoreMockDelete() {
    local -i size

    # Test deletion for default context
    echo : > ${SIMBOL_USER_MOCKENV?}.default

    mock:clear default

    test -e ${SIMBOL_USER_MOCKENV?}.default
    assertTrue "${FUNCNAME?}/1.1" $?
    size=$(stat --printf '%s\n' "${SIMBOL_USER_MOCKENV?}.default" 2>/dev/null)
    assertEquals "${FUNCNAME?}/1.2" 0 ${size}

    # Test deletion for custom context
    echo : > ${SIMBOL_USER_MOCKENV?}.a
    echo : > ${SIMBOL_USER_MOCKENV?}.b
    echo : > ${SIMBOL_USER_MOCKENV?}.custom

    mock:clear custom

    test -e ${SIMBOL_USER_MOCKENV?}.a
    assertTrue "${FUNCNAME?}/2.1.1" $?
    size=$(stat --printf '%s\n' "${SIMBOL_USER_MOCKENV?}.a" 2>/dev/null)
    assertEquals "${FUNCNAME?}/2.1.2" 2 ${size}

    test -e ${SIMBOL_USER_MOCKENV?}.b
    assertTrue "${FUNCNAME?}/2.2.1" $?
    size=$(stat --printf '%s\n' "${SIMBOL_USER_MOCKENV?}.b" 2>/dev/null)
    assertEquals "${FUNCNAME?}/2.2.2" 2 ${size}

    test -e ${SIMBOL_USER_MOCKENV?}.custom
    assertTrue "${FUNCNAME?}/2.3.1" $?
    size=$(stat --printf '%s\n' "${SIMBOL_USER_MOCKENV?}.custom" 2>/dev/null)
    assertEquals "${FUNCNAME?}/2.3.2" 0 ${size}

    # Test deletion of all mock contexts
    echo : > ${SIMBOL_USER_MOCKENV?}.default
    mock:clear

    test -e ${SIMBOL_USER_MOCKENV?}.default
    assertTrue "${FUNCNAME?}/3.1.1" $?
    size=$(stat --printf '%s\n' "${SIMBOL_USER_MOCKENV?}.default" 2>/dev/null)
    assertEquals "${FUNCNAME?}/3.1.2" 0 ${size}

    test -e ${SIMBOL_USER_MOCKENV?}.a
    assertFalse "${FUNCNAME?}/3.2" $?
    test -e ${SIMBOL_USER_MOCKENV?}.b
    assertFalse "${FUNCNAME?}/3.3" $?
    test -e ${SIMBOL_USER_MOCKENV?}.custom
    assertFalse "${FUNCNAME?}/3.4" $?
}

function exitWith() {
  g_CACHE_OUT || {
    md5sum <<< "$(date +%N)" | cut -b 1-32
    core:return $1
  } > ${g_CACHE_FILE?}; g_CACHE_IN; return $?
}

function testCoreCacheExit() {
    #. Negative returns do not get cached...
    for i in {1..2}; do
        exitWith 1
        assertEquals "0.1.1.$i" 1 $?

        exitWith 9
        assertEquals "0.1.2.$i" 9 $?

        exitWith 99
        assertEquals "0.1.3.$i" 99 $?
    done

    #. Positive ones do...
    local o1
    o1="$(exitWith 0)"
    assertTrue "0.2.1" $?

    local o2
    o2=$(exitWith 0)
    assertTrue "0.2.2.1" $?
    assertEquals "0.2.2.2" "${o1}" "${o2}"

    local o3
    o3=$(exitWith 0)
    assertTrue "0.2.3.1" $?
    assertEquals "0.2.3.2" "${o1}" "${o3}"
}

function testCoreCache() {
    local -i hit

    assertEquals '0.1.1' 2 $counter

    for hit in {1..3}; do
        coreCacheTester 3 up
        assertEquals "0.2.${hit}.1" 102 $counter
        coreCacheTester 3 down
        assertEquals "0.2.${hit}.2" 102 $counter
    done
    sleep 2

    coreCacheTester 1 jump
    assertEquals "0.3" 1102 $counter
    for hit in {1..3}; do
        coreCacheTester 3 up
        assertEquals "0.3.${hit}.1" 1102 $counter
        coreCacheTester 3 down
        assertEquals "0.3.${hit}.2" 1102 $counter
    done
    sleep 4

    for hit in {1..3}; do
        coreCacheTester 3 down
        assertEquals "0.4.${hit}.1" 1092 $counter
        coreCacheTester 3 up
        assertEquals "0.4.${hit}.2" 1092 $counter
    done
}
