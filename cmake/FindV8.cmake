function(set_glob_abs VAR GLOBBING EXTS DIRECTORY)
  set(GLOBS)
  foreach(ext ${EXTS})
    list(APPEND GLOBS "${DIRECTORY}/*.${ext}")
  endforeach()
  file(${GLOBBING} GLOB_RESULT ${GLOBS})
  list(SORT GLOB_RESULT)
  set(FILES)
  foreach(file ${ARGN})
    list(APPEND FILES "${DIRECTORY}/${file}")
  endforeach()

  if(NOT FILES STREQUAL GLOB_RESULT)
    message(AUTHOR_WARNING "${VAR} does not contain every file from directory ${DIRECTORY}")
    set(LIST_BUT_NOT_GLOB)
    if(POLICY CMP0057)
      cmake_policy(SET CMP0057 NEW)
      foreach(file ${FILES})
        if(NOT file IN_LIST GLOB_RESULT)
          list(APPEND LIST_BUT_NOT_GLOB ${file})
        endif()
      endforeach()
      if(LIST_BUT_NOT_GLOB)
        message(AUTHOR_WARNING "Entries only present in ${VAR}: ${LIST_BUT_NOT_GLOB}")
      endif()
      set(GLOB_BUT_NOT_LIST)
      foreach(file ${GLOB_RESULT})
        if(NOT file IN_LIST FILES)
          list(APPEND GLOB_BUT_NOT_LIST ${file})
        endif()
      endforeach()
      if(GLOB_BUT_NOT_LIST)
        message(AUTHOR_WARNING "Entries only present in ${DIRECTORY}: ${GLOB_BUT_NOT_LIST}")
      endif()
      if(NOT LIST_BUT_NOT_GLOB AND NOT GLOB_BUT_NOT_LIST)
        message(AUTHOR_WARNING "${VAR} is not alphabetically sorted")
      endif()
    endif()
  endif()

  set(${VAR} ${FILES} PARENT_SCOPE)
endfunction()

function(set_src_abs VAR GLOBBING DIRECTORY) # ...
  set_glob_abs(${VAR} ${GLOBBING} "c;cpp;h" ${DIRECTORY} ${ARGN})
  set(${VAR} ${${VAR}} PARENT_SCOPE)
endfunction()

include_directories(/usr/include/nodejs/deps/v8/include)

set(V8
        -Wl,--start-group
        v8_base
        v8_libbase
        v8_external_snapshot
        v8_libplatform
        v8_libsampler
        icuuc
        icui18n
        rt
        dl
        -Wl,--end-group
        )
link_directories(
        /usr/include/nodejs/deps/v8/include
)

# target_link_libraries(project ${CMAKE_THREAD_LIBS_INIT} ${SDL2_LIBRARY} ${LIBV8})



set(V8_SRC_DIR /usr/include/nodejs/deps/v8/include)

set_src_abs(V8_SRC GLOB_RECURSE ${V8_SRC_DIR}
  libplatform/libplatform-export.h
  libplatform/libplatform.h
  libplatform/v8-tracing.h
  v8-inspector-protocol.h
  v8-inspector.h
  v8-platform.h
  v8-profiler.h
  v8-testing.h
  v8-util.h
  v8-value-serializer-version.h
  v8-version-string.h
  v8-version.h
  v8.h
  v8config.h
)

add_library(V8 EXCLUDE_FROM_ALL OBJECT ${V8_SRC})
set(V8_DEP $<TARGET_OBJECTS:V8>)
set(V8_INCLUDEDIR ${V8_SRC_DIR})
set(V8_INCLUDE_DIRS ${V8_INCLUDEDIR})

list(APPEND TARGETS_DEP V8)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(V8 DEFAULT_MSG V8_INCLUDEDIR)
set(V8_BUNDLED ON)
