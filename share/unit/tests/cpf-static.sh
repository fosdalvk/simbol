# vim: tw=0:ts=4:sw=4:et:ft=bash

function cpfSetUp() {
    :noop
}

function cpfTearDown() {
    :noop
}

function testCoreCpfPublic() {
    local data
    data="$(cpf "Hello World")"
    assertTrue  "${FUNCNAME?}/1.1" $?
    assertEquals  "${FUNCNAME?}/1.2" "${data}" "Hello World"
    if [ ${SIMBOL_IN_COLOR} -eq 1 ]; then
        assertEquals  "${FUNCNAME?}/1.3.1"\
            "$(cpf "%{ul:%s}" "Hello World")"\
            "$(echo -e "\E[4mHello World\E[24m")"
    else
        assertEquals  "${FUNCNAME?}/1.3.2"\
            "$(cpf "%{ul:%s}" "Hello World")"\
            "$(echo -e "Hello World")"
    fi
}

function testCoreCpfModule_is_modifiedPrivate() {
    core:wrapper cpf ::module_is_modified $(core:module_path dns) dns
    assertFalse  "${FUNCNAME?}/1" $?
}

function testCoreCpfModule_has_alertsPrivate() {
    local data

    #. TODO: mock a tempfile, do not use an actual module
    data=$(core:wrapper cpf ::module_has_alerts $(core:module_path remote) remote)
    assertTrue  "${FUNCNAME?}/1" $?

    #. TODO: mock a tempfile, do not use an actual module
    data=$(core:wrapper cpf ::module_has_alerts  $(core:module_path dns) dns)
    assertFalse  "${FUNCNAME?}/2" $?
}

function testCoreCpfModulePrivate() {
    : noop
}

function testCoreCpfFunction_has_alertsPrivate() {
    local data

    #. TODO: mock a tempfile, do not use an actual module
    data="$(core:wrapper cpf ::function_has_alerts $(core:module_path remote) remote cluster)"
    assertTrue  "${FUNCNAME?}/1" $?

    #. TODO: mock a tempfile, do not use an actual module
    data="$(core:wrapper cpf ::function_has_alerts $(core:module_path dns) dns resolve)"
    assertFalse  "${FUNCNAME?}/2" $?

    #. TODO: mock a tempfile, do not use an actual module
    data="$(core:wrapper cpf ::function_has_alerts $(core:module_path remote) remote clusterfoo)"
    assertFalse  "${FUNCNAME?}/3" $?
}

function testCoreCpfFunctionPrivate() {
    : noop
}

function testCoreCpfIs_fmtPrivate() {
    core:wrapper cpf ::is_fmt '%s'
    assertTrue  "${FUNCNAME?}/1" $?

    core:wrapper cpf ::is_fmt '%%s'
    assertTrue  "${FUNCNAME?}/2" $?

    core:wrapper cpf ::is_fmt '%'
    assertFalse  "${FUNCNAME?}/3" $?

    core:wrapper cpf ::is_fmt '%{%ss}'
    assertTrue  "${FUNCNAME?}/4" $?

    core:wrapper cpf ::is_fmt '%{%ss}%'
    assertTrue  "${FUNCNAME?}/5" $?
}

function testCoreCpfThemePrivate() {
    local out
    out=$(core:wrapper cpf ::theme "@host" "%s")
    assertTrue  "${FUNCNAME?}/1.1" $?
    assertEquals  "${FUNCNAME?}/1.2" "${out}" "@ %{y:%s} %s"
    assertEquals  "${FUNCNAME?}/1.3"\
        "$(core:wrapper cpf ::theme "@netgroup" "%s")"\
        "+ %{c:%s} %s"
}

function testCoreCpfIndentPublic() {
    local out
    CPF_INDENT=0
    out=$(cpfi foo)
    assertTrue  "${FUNCNAME?}/1.1" $?
    assertEquals  "${FUNCNAME?}/1.2" "${out}" "foo"
    -=[
    assertEquals  "${FUNCNAME?}/1.3" 1 ${CPF_INDENT}
    out=$(cpfi foo)
    assertEquals  "${FUNCNAME?}/1.4"\
        "${out}"\
        "$(printf "%$((CPF_INDENT * USER_CPF_INDENT_SIZE))s" "${USER_CPF_INDENT_STR}")foo"
    -=[
    -=[
    -=[
    assertEquals  "${FUNCNAME?}/1.5" 4 ${CPF_INDENT}
    ]=-
    ]=-
    assertEquals  "${FUNCNAME?}/1.6" 2 ${CPF_INDENT}
}
