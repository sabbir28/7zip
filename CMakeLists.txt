cmake_minimum_required(VERSION 3.20)

project(7-Zip
    VERSION 26.05.0
    DESCRIPTION "High-performance open-source file archiver with high compression ratio"
    HOMEPAGE_URL "https://7-zip.org"
    LANGUAGES C CXX
)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Platform Identification
if(WIN32)
    add_compile_definitions(
        UNICODE
        _UNICODE
        _CRT_SECURE_NO_WARNINGS
        WIN32_LEAN_AND_MEAN
    )
    if(MSVC)
        add_compile_options(/W4 /EHsc /MP)
    endif()
endif()

# Core Include Directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/C
    ${CMAKE_CURRENT_SOURCE_DIR}/CPP
    ${CMAKE_CURRENT_SOURCE_DIR}/CPP/Common
    ${CMAKE_CURRENT_SOURCE_DIR}/CPP/Windows
    ${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip
    ${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Common
)

# Automated Native MSVC Build Target for 7zz
if(WIN32)
    find_program(NMAKE_EXECUTABLE nmake)
    if(NMAKE_EXECUTABLE)
        add_custom_target(7zz ALL
            COMMAND ${NMAKE_EXECUTABLE}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Bundles/Alone2"
            COMMENT "Compiling 7zz (Standalone 7-Zip CLI) via NMAKE..."
        )

        add_custom_target(7za
            COMMAND ${NMAKE_EXECUTABLE}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Bundles/Alone"
            COMMENT "Compiling 7za (Standalone 7-Zip Light CLI) via NMAKE..."
        )

        add_custom_target(7zFM
            COMMAND ${NMAKE_EXECUTABLE}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Bundles/Fm"
            COMMENT "Compiling 7zFM (7-Zip File Manager GUI) via NMAKE..."
        )
    endif()
endif()

# Automated Testing Registration
enable_testing()

if(WIN32)
    add_test(NAME Test7zzExecution
        COMMAND powershell -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_SOURCE_DIR}/scripts/test.ps1"
    )
endif()
