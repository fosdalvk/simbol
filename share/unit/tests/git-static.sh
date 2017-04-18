# vim: tw=0:ts=4:sw=4:et:ft=bash

function testCoreGitImport() {
    core:softimport git
    assertTrue "${FUNCNAME?}/0" $?
}

function gitSetUp() {
    git config --global user.email > /dev/null
    [ $? -eq 0 ] || git config --global user.email "travis.c.i@unit-testing.org"

    git config --global user.name > /dev/null
    [ $? -eq 0 ] || git config --global user.name "Travis C. I."

    declare -g g_PLAYGROUND="/tmp/git-pg.$$"
    core:wrapper git playground "${g_PLAYGROUND}" >& /dev/null
    assertTrue "${FUNCNAME?}/0" $?
}

function gitTearDown() {
    rm -rf ${g_PLAYGROUND?}
}

function testCoreGitFilePublic() {
    core:import git

    cd ${g_PLAYGROUND?}

    local -i c

    c=$(core:wrapper git file BadFile | wc -l 2>${stderrF?})
    assertEquals "${FUNCNAME?}/0" 0 ${c} #. nothing here yet

    #. Add it
    echo "Evil" > BadFile
    git add BadFile >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/1" $?

    git commit BadFile -m "BadFile added" >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/2" $?

    c=$(core:wrapper git file BadFile | wc -l 2>${stderrF?})
    assertEquals "${FUNCNAME?}/3" 1 ${c} #. added

    #. Delete it
    git rm BadFile >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/4" $?

    git commit BadFile -m "BadFile removed" >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/5" $?

    c=$(core:wrapper git file BadFile | wc -l 2>${stderrF?})
    assertEquals "${FUNCNAME?}/6" 2 ${c} #. added and removed

    #. Remove it from history
    core:wrapper git rm BadFile >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/7" $?

    #. Assert it is really gone
    c=$(core:wrapper git file BadFile | wc -l 2>${stderrF?})
    assertEquals "${FUNCNAME?}/8" 0 ${c}
}

function testCoreGitVacuumPublic() {
    core:import git

    core:wrapper git vacuum ${g_PLAYGROUND?} >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/0" $?
}

function testCoreGitPlaygroundPublic() {
    core:import git
    : ${g_PLAYGROUND?}
    rm -rf ${g_PLAYGROUND}

    core:wrapper git playground ${g_PLAYGROUND} >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/0" $?

    core:wrapper git playground ${g_PLAYGROUND} >${stdoutF?} 2>${stderrF?}
    assertFalse "${FUNCNAME?}/0" $?
}

function testCoreGitCommitallPublic() {
    core:import git
    : ${g_PLAYGROUND?}
    rm -rf ${g_PLAYGROUND}

    core:wrapper git playground ${g_PLAYGROUND} >${stdoutF?} 2>${stderrF?}
    cd ${g_PLAYGROUND}
    git clean -q -f #. remove uncommitted crap from playground command first

    #. add 101 files
    for i in {1..101}; do
        local fN="fileA-${i}.data"
        dd if=/dev/urandom of=${fN} bs=1024 count=1 >${stdoutF?} 2>${stderrF?}
        git add ${fN}.data >${stdoutF?} 2>${stderrF?}
    done

    #. run commitall
    core:wrapper git commitall >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/0" $?

    #. look for individual commits
    local -i committed=$(git log --pretty=format:'%s'|grep '^\.\.\.'|wc -l)
    assertEquals "${FUNCNAME?}/1" 101 ${committed}
}

function testCoreGitSplitPublic() {
    core:import git
    : ${g_PLAYGROUND?}
    rm -rf ${g_PLAYGROUND}

    core:wrapper git playground ${g_PLAYGROUND} >${stdoutF?} 2>${stderrF?}
    cd ${g_PLAYGROUND}
    git clean -q -f #. remove uncommitted crap from playground command first

    #. add 99 files
    for i in {1..99}; do
        local fN="fileB-${i}.data"
        dd if=/dev/urandom of=${fN} bs=1024 count=1 >${stdoutF?} 2>${stderrF?}
    done

    #. commit them all in one hit
    git add fileB-*.data >${stdoutF?} 2>${stderrF?}
    git commit -a -m '99 files added' >${stdoutF?} 2>${stderrF?}

    local -i committed

    #. look for single commits
    committed=$(git log --pretty=format:'%s'|grep '^\.\.\.'|wc -l)
    assertEquals "${FUNCNAME?}/1" 0 ${committed}

#. TODO: This is interactive due to the `git rebase -i'
#    #. now split them up
#    core:wrapper git split HEAD >${stdoutF?} 2>${stderrF?}
#
#    #. test it worked
#    committed=$(git log --pretty=format:'%s'|grep '^\.\.\.'|wc -l)
#    assertEquals "${FUNCNAME?}/2" 99 ${committed}
}

function testCoreGitBasedirInternal() {
    core:import git
    : ${g_PLAYGROUND?}

    cd ${g_PLAYGROUND}

    :git:basedir ${g_PLAYGROUND} >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/0" $?

    :git:basedir ${g_PLAYGROUND}.wat >${stdoutF?} 2>${stderrF?}
    assertFalse "${FUNCNAME?}/0" $?

    :git:basedir /tmp >${stdoutF?} 2>${stderrF?}
    assertFalse "${FUNCNAME?}/0" $?
}

function testCoreGitSizePublic() {
    core:import git

    cd /
    core:wrapper git size ${g_PLAYGROUND?} >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/0" $?

    cd ${g_PLAYGROUND?}
    core:wrapper git size >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/1" $?

    cd ${g_PLAYGROUND?}/module
    core:wrapper git size >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/2" $?
}

function testCoreGitUsagePublic() {
    core:import git

    cd /
    core:wrapper git usage ${g_PLAYGROUND?} >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/0" $?

    cd ${g_PLAYGROUND?}
    core:wrapper git usage >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/1" $?

    cd ${g_PLAYGROUND?}/module
    core:wrapper git usage >${stdoutF?} 2>${stderrF?}
    assertTrue "${FUNCNAME?}/2" $?
}
