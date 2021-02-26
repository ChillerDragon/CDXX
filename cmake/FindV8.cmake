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
  pkg_check_modules(PC_V8 v8)
endif()

set_extra_dirs_lib(V8 v8)
find_library(V8_LIBRARY
  NAMES v8.dll v8_libbase.dll icui18n.dll icuuc.dll v8_libplatform.dll v8 v8_libbase icui18n icuuc v8_libplatform
  HINTS ${HINTS_V8_LIBDIR} ${V8_LIBDIR} ${PC_V8_LIBDIR} ${PC_V8_LIBRARY_DIRS}
  PATHS ${PATHS_V8_LIBDIR}
  ${CROSSCOMPILING_NO_CMAKE_SYSTEM_PATH}
)
set(CMAKE_FIND_FRAMEWORK FIRST)
set_extra_dirs_include(V8 v8 "${V8_LIBRARY}")
find_path(V8_INCLUDEDIR v8.h
  PATH_SUFFIXES V8
  HINTS ${HINTS_V8_INCLUDEDIR} ${V8_INCLUDE_DIRS} ${PC_V8_INCLUDEDIR} ${PC_V8_INCLUDE_DIRS}
  PATHS ${PATHS_V8_INCLUDEDIR}
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(V8 DEFAULT_MSG V8_LIBRARY V8_INCLUDEDIR)

mark_as_advanced(V8_LIBRARY V8_INCLUDEDIR)

if(V8_FOUND)
  set(V8_LIBRARIES ${V8_LIBRARY})
  set(V8_INCLUDE_DIRS ${V8_INCLUDEDIR})

  is_bundled(V8_BUNDLED "${V8_LIBRARY}")
  if(V8_BUNDLED AND TARGET_OS STREQUAL "windows")
    set(V8_COPY_FILES
          "${EXTRA_V8_LIBDIR}/v8.dll"
          "${EXTRA_V8_LIBDIR}/v8_libbase.dll"
          "${EXTRA_V8_LIBDIR}/icui18n.dll"
          "${EXTRA_V8_LIBDIR}/icuuc.dll"
          "${EXTRA_V8_LIBDIR}/v8_libplatform.dll"
          "${EXTRA_V8_LIBDIR}/icudtl.dat"
      )
  else()
    set(V8_COPY_FILES)
  endif()
endif()
