# vim: tw=0:ts=4:sw=4:et:ft=bash

#. Scaffolding -={
function moduleScaffold() {
    local -i e=0

    local cl="${1^}"
    local modulefn="${g_RUNTIME_MODULECAPS,}${cl}"

    local -i verbose
    case $1 in
        setUp|tearDown) let verbose=${FALSE?} ;;
        oneTimeSetUp|oneTimeTearDown) let verbose=${TRUE?} ;;
    esac

    [ ${verbose} -eq ${FALSE?} ] || cpfi "%{@comment:${modulefn}...}"
    #. (awsEc2SetUp/awsEc2TearDown)

    if [ -f ${g_RUNTIME_SCRIPT?} ]; then
        if [ $? -eq 0 ]; then
            if [ "$(type -t ${modulefn} 2>/dev/null)" == "function" ]; then
                ${modulefn}
                e=$?
                if [ ${verbose} -eq ${TRUE} ]; then
                    if [ $e -eq 0 ]; then
                        theme HAS_PASSED
                    else
                        theme HAS_FAILED
                    fi
                fi
            else
                [ ${verbose} -eq ${FALSE?} ] ||
                    theme HAS_WARNED "UNDEFINED:${modulefn}"
            fi
        else
            [ ${verbose} -eq ${FALSE?} ] ||
                theme HAS_FAILED
            e=${CODE_FAILURE?}
        fi
    else
        [ ${verbose} -eq ${FALSE?} ] ||
            theme HAS_PASSED "DYNAMIC_ONLY"
    fi

    return $e
}

function oneTimeSetUp() {
    -=[

    cpfi "%{@comment:unitSetUp...}"
    local -i e=${CODE_SUCCESS?}

    declare -gi tid=0

    declare -g oD="${SHUNIT_TMPDIR?}"
    mkdir -p "${oD}"

    declare -g stdoutF="${oD}/stdout"
    declare -g stderrF="${oD}/stderr"

    theme HAS_PASSED

    moduleScaffold oneTimeSetUp
    e=$?

    -=[

    return $e
}

function oneTimeTearDown() {
    local -i e=${CODE_SUCCESS?}

    ]=-

    moduleScaffold oneTimeTearDown
    e=$?

    cpfi "%{@comment:unitTearDown...}"
    rm -rf "${oD?}"
    theme HAS_PASSED

    ]=-

    return $e
}

function setUp() {
    cpf:initialize 1
    moduleScaffold setUp

    : ${tid?}
    ((tid++))
    tidstr=$(printf "%03d" ${tid})
    cpfi "%{@comment:Test} %{y:#%s} " "${tidstr}"
}

function tearDown() {
    moduleScaffold tearDown
}
#. }=-
