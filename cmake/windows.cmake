set(WIN_SDK_LOG_HEAD   "Windows manifest workaround -- ")

if (${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    # Setup nuget package information
    message(STATUS "${WIN_SDK_LOG_HEAD} Enabled")
    set(WIN_SDK_NUGET_URL  https://www.nuget.org/api/v2/package/Microsoft.Windows.SDK.CPP/10.0.26100.4654)
    set(WIN_SDK_NUGET_FILE ${CMAKE_BINARY_DIR}/.nuget/Microsoft.Windows.SDK.CPP/10.0.26100.4654.nuget)
    set(WIN_SDK_NUGET_HASH 39173D78EC05C7C123928FD45F5F3B84D2933C1A87CEC015C90227B30BC950BD)

    # Download nuget package
    if (NOT EXISTS ${WIN_SDK_NUGET_FILE})
        message(STATUS "${WIN_SDK_LOG_HEAD} not found, download...")
        file(DOWNLOAD ${WIN_SDK_NUGET_URL} ${WIN_SDK_NUGET_FILE})
        if (NOT EXISTS ${WIN_SDK_NUGET_FILE})
            message(FATAL_ERROR "${WIN_SDK_LOG_HEAD} download failed")
        endif ()
    endif ()

    # Verify sha256
    message(STATUS "${WIN_SDK_LOG_HEAD} downloaded, verify...")
    file(SHA256 ${WIN_SDK_NUGET_FILE} WIN_SDK_NUGET_HASH_REAL)
    string(TOUPPER ${WIN_SDK_NUGET_HASH_REAL} WIN_SDK_NUGET_HASH_REAL)
    if (${WIN_SDK_NUGET_HASH} STREQUAL ${WIN_SDK_NUGET_HASH_REAL})
        message(STATUS "${WIN_SDK_LOG_HEAD} verified")
    elseif ()
        file(REMOVE ${WIN_SDK_NUGET_FILE})
        message(FATAL_ERROR "${WIN_SDK_LOG_HEAD} verify failed")
    endif ()

    # Extract files
    set(WIN_SDK_ROOT ${CMAKE_BINARY_DIR}/windows/sdk)
    if (NOT EXISTS ${WIN_SDK_ROOT})
        set(WIN_SDK_EXTRACT_ROOT ${CMAKE_BINARY_DIR}/.cache/extract)
        file(ARCHIVE_EXTRACT
            INPUT ${WIN_SDK_NUGET_FILE}
            DESTINATION ${WIN_SDK_EXTRACT_ROOT}
        )
        file(MAKE_DIRECTORY ${WIN_SDK_ROOT})
        file(REMOVE_RECURSE ${WIN_SDK_ROOT})
        file(RENAME ${WIN_SDK_EXTRACT_ROOT}/c ${WIN_SDK_ROOT})
        file(REMOVE_RECURSE ${WIN_SDK_EXTRACT_ROOT})
    endif ()

    # Find mt.exe
    set(WIN_SDK_BIN_PATH "${WIN_SDK_ROOT}/bin/10.0.26100.0")
    set(WIN_SDK_MT_PATH "")
    if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86")
        set(WIN_SDK_MT_PATH "${WIN_SDK_BIN_PATH}/x86/mt.exe")
    elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "AMD64")
        set(WIN_SDK_MT_PATH "${WIN_SDK_BIN_PATH}/x64/mt.exe")
    elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "ARM64")
        set(WIN_SDK_MT_PATH "${WIN_SDK_BIN_PATH}/arm64/mt.exe")
    else ()
        message(FATAL_ERROR "${WIN_SDK_LOG_HEAD} unknown processor architecture ${CMAKE_SYSTEM_PROCESSOR}")
    endif ()
    if (NOT EXISTS ${WIN_SDK_MT_PATH})
        message(FATAL_ERROR "${WIN_SDK_LOG_HEAD} ${WIN_SDK_MT_PATH} not found")
    endif ()
    message(STATUS "${WIN_SDK_LOG_HEAD} using ${WIN_SDK_MT_PATH}")

    # Import mt.exe
    add_executable(windows-sdk-mt IMPORTED GLOBAL)
    set_target_properties(windows-sdk-mt PROPERTIES
        IMPORTED_LOCATION ${WIN_SDK_MT_PATH}
    )

    # Merge manifest file to win32 executable
    function (target_win32_manifest target manifest)
        # https://learn.microsoft.com/en-us/cpp/build/reference/manifest-create-side-by-side-assembly-manifest?view=msvc-170
        set(WIN32_RES_ID_EXE 1)
        set(WIN32_RES_ID_DLL 2)
        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND $<TARGET_FILE:windows-sdk-mt> -nologo -manifest "${manifest}" "-outputresource:$<TARGET_FILE:${target}>;#${WIN32_RES_ID_EXE}"
        )
    endfunction ()
else ()
    # No-op
    function (target_win32_manifest target manifest)
        message(VERBOSE "${WIN_SDK_LOG_HEAD} disabled for target ${target} (manifest ${manifest})")
    endfunction ()
endif ()
