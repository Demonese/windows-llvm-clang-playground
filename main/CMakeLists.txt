add_executable(main)

target_compile_options(main PRIVATE
    $<$<C_COMPILER_ID:Clang>:-Wall>
    $<$<C_COMPILER_ID:Clang>:-Wextra>
    $<$<CXX_COMPILER_ID:Clang>:-Wall>
    $<$<CXX_COMPILER_ID:Clang>:-Wextra>
)

target_link_options(main PRIVATE
    # lld-link bug workaround
    $<$<CXX_COMPILER_ID:Clang>:LINKER:/manifestuac:no>
)

target_compile_features(main PRIVATE
    c_std_23
    cxx_std_23
)

set_target_properties(main PROPERTIES
    C_EXTENSIONS OFF
    CXX_EXTENSIONS OFF
)

target_compile_definitions(main PRIVATE
    _UNICODE
    UNICODE
)

target_sources(main PRIVATE
    main.cpp
    main.manifest
)
