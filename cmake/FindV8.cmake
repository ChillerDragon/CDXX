if(NOT PREFER_BUNDLED_LIBS)
  set(CMAKE_MODULE_PATH ${ORIGINAL_CMAKE_MODULE_PATH})
  find_package(V8)
  set(CMAKE_MODULE_PATH ${OWN_CMAKE_MODULE_PATH})
  if(V8_FOUND)
    set(V8_BUNDLED OFF)
    set(V8_DEP)
  endif()
endif()

if(NOT CMAKE_CROSSCOMPILING)
  find_package(PkgConfig QUIET)
  pkg_check_modules(PC_V8 REQUIRED IMPORTED_TARGET GLOBAL v8 v8_libplatform)
endif()

set(CMAKE_FIND_FRAMEWORK FIRST)
find_path(V8_INCLUDEDIR v8.h
  PATH_SUFFIXES V8
  HINTS ${HINTS_V8_INCLUDEDIR} ${V8_INCLUDE_DIRS} ${PC_V8_INCLUDEDIR} ${PC_V8_INCLUDE_DIRS}
  PATHS ${PATHS_V8_INCLUDEDIR}
)

find_file(V8_SNAPSHOT_BLOB bin/snapshot_blob.bin REQUIRED)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(V8 DEFAULT_MSG V8_INCLUDEDIR)

mark_as_advanced(V8_INCLUDEDIR)

if(V8_FOUND)
  set(V8_INCLUDE_DIRS ${V8_INCLUDEDIR})
  set(V8_COPY_FILES ${V8_SNAPSHOT_BLOB})
endif()
