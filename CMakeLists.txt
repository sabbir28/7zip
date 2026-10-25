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

        add_custom_target(7zG
            COMMAND ${NMAKE_EXECUTABLE}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/UI/GUI"
            COMMENT "Compiling 7zG (7-Zip GUI Dialogs) via NMAKE..."
        )

        add_custom_target(7z_dll
            COMMAND ${NMAKE_EXECUTABLE}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Bundles/Format7zF"
            COMMENT "Compiling 7z.dll (Full Archive Engine DLL) via NMAKE..."
        )

        add_custom_target(7z_sfx
            COMMAND ${NMAKE_EXECUTABLE}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Bundles/SFXWin"
            COMMENT "Compiling 7z.sfx (Windows GUI Self-Extracting Stub) via NMAKE..."
        )

        add_custom_target(7zCon_sfx
            COMMAND ${NMAKE_EXECUTABLE}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/Bundles/SFXCon"
            COMMENT "Compiling 7zCon.sfx (Console Self-Extracting Stub) via NMAKE..."
        )

        add_custom_target(7_zip_dll
            COMMAND ${NMAKE_EXECUTABLE}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/CPP/7zip/UI/Explorer"
            COMMENT "Compiling 7-zip.dll (Explorer Shell Extension) via NMAKE..."
        )

        add_custom_target(gui
            DEPENDS 7zFM 7zG 7z_dll 7_zip_dll 7z_sfx
            COMMENT "Building all 7-Zip GUI binaries..."
        )

        add_custom_target(sfx
            DEPENDS 7z_sfx 7zCon_sfx
            COMMENT "Building all 7-Zip SFX modules..."
        )
    endif()
endif()

# Automated Testing Registration
enable_testing()

if(WIN32)
    add_test(NAME Test7zzExecution
        COMMAND powershell -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_SOURCE_DIR}/scripts/test.ps1"
    )

    add_test(NAME TestZipToExeSFX
        COMMAND powershell -ExecutionPolicy Bypass -Command "
            $tmp = Join-Path $env:TEMP ('sfx_cmake_test_' + [Guid]::NewGuid().ToString('N'));
            New-Item -ItemType Directory -Path $tmp -Force | Out-Null;
            'Hello from SFX' | Out-File (Join-Path $tmp 'test.txt');
            & '${CMAKE_CURRENT_SOURCE_DIR}/bin/x64/7zz.exe' a (Join-Path $tmp 'archive.zip') (Join-Path $tmp 'test.txt');
            & powershell -ExecutionPolicy Bypass -File '${CMAKE_CURRENT_SOURCE_DIR}/scripts/zip_to_exe.ps1' -InputPath (Join-Path $tmp 'archive.zip') -OutputPath (Join-Path $tmp 'archive.exe') -Test;
            $pass = Test-Path (Join-Path $tmp 'archive.exe');
            Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue;
            if (-not $pass) { exit 1 }
        "
    )

    add_test(NAME TestOSIntegration
        COMMAND powershell -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_SOURCE_DIR}/scripts/integrate_os.ps1" -Status
    )
endif()
