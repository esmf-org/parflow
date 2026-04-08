cmake_minimum_required (VERSION 3.5.2)

### Build Flags
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "${CMAKE_Fortran_FLAGS_RELWITHDEBINFO} -fbacktrace")
  set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -O0 -fbacktrace -fcheck=all" )
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "${CMAKE_Fortran_FLAGS_RELWITHDEBINFO} -traceback")
  set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -O0 -traceback -check all")
endif()

### Find and Include ESMF
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/")
find_package(ESMF MODULE REQUIRED)

### Include ESMF Compiler Options
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${ESMF_F90COMPILEOPTS}")

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/include)

### Library Files
list(APPEND pf_nuopc_files
  src/pf_nuopc_cap.F90
  src/pf_nuopc_fields.F90
  src/pf_nuopc_grid.F90
  src/pf_nuopc_flags.F90
)

### New Library: parflow_nuopc
add_library(parflow_nuopc STATIC ${pf_nuopc_files})
set_target_properties(parflow_nuopc PROPERTIES
  Fortran_MODULE_DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}
)
add_dependencies(parflow_nuopc pfsimulator)
target_include_directories(parflow_nuopc PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_Fortran_MODULE_DIRECTORY}>
  $<INSTALL_INTERFACE:include>
)
target_link_libraries(parflow_nuopc PUBLIC ESMF)
target_link_libraries(parflow_nuopc PUBLIC pfsimulator)

# configure parflow esmx executable
if (PARFLOW_ENABLE_ESMX)
  if(ESMF_VERSION VERSION_LESS "8.9.0")
    message(FATAL_ERROR "ESMX requires ESMF version 8.9.0 or greater")
  endif (ESMF_VERSION VERSION_LESS "8.9.0")

  set(ESMX_BUILD_FILE ${CMAKE_CURRENT_SOURCE_DIR}/esmxBuild.yaml)

  # Determine Python executable for ESMX configuration
  if(NOT DEFINED Python_EXECUTABLE)
    if(DEFINED Python3_EXECUTABLE)
      set(Python_EXECUTABLE ${Python3_EXECUTABLE})
    elseif(DEFINED PYTHON_EXECUTABLE)
      set(Python_EXECUTABLE ${PYTHON_EXECUTABLE})
    else()
      find_package(Python3 QUIET COMPONENTS Interpreter)
      if(Python3_Interpreter_FOUND)
        set(Python_EXECUTABLE ${Python3_EXECUTABLE})
      else()
        find_package(PythonInterp REQUIRED)
        set(Python_EXECUTABLE ${PYTHON_EXECUTABLE})
      endif()
    endif()
  endif()

  # Bootstrap Python virtual environment for ESMX configuration
  set(ESMX_VENV_PYTHON ${CMAKE_BINARY_DIR}/esmx/bin/python3)
  if(NOT EXISTS ${ESMX_VENV_PYTHON})
    message(STATUS "Bootstrapping ${ESMX_VENV_PYTHON} for ESMX configure")
    execute_process(
      COMMAND ${Python_EXECUTABLE} -m venv ${CMAKE_BINARY_DIR}/esmx
      RESULT_VARIABLE ESMX_VENV_RET
    )
    if(NOT ESMX_VENV_RET EQUAL 0)
      message(FATAL_ERROR "Failed to create Python virtual environment for ESMX")
    endif()
  endif()
  set(Python_EXECUTABLE ${ESMX_VENV_PYTHON})

  # Install pyyaml in the ESMX virtual environment
  execute_process(
    COMMAND ${Python_EXECUTABLE} -c "import yaml"
    RESULT_VARIABLE ESMX_PYYAML_RET
    OUTPUT_QUIET
    ERROR_QUIET
  )
  if(NOT ESMX_PYYAML_RET EQUAL 0)
    execute_process(
      COMMAND ${Python_EXECUTABLE} -m pip install --upgrade pip wheel setuptools
      RESULT_VARIABLE ESMX_PIP_BOOTSTRAP_RET
    )
    if(NOT ESMX_PIP_BOOTSTRAP_RET EQUAL 0)
      message(FATAL_ERROR "Failed to prepare pip for ${Python_EXECUTABLE}")
    endif()

    execute_process(
      COMMAND ${Python_EXECUTABLE} -m pip install pyyaml
      RESULT_VARIABLE ESMX_PYYAML_INSTALL_RET
    )
    if(NOT ESMX_PYYAML_INSTALL_RET EQUAL 0)
      message(FATAL_ERROR "Failed to install pyyaml for ${Python_EXECUTABLE}")
    endif()
  endif()

  add_subdirectory(${ESMF_ESMXDIR} ${CMAKE_BINARY_DIR}/ESMX)
endif (PARFLOW_ENABLE_ESMX)

### Install Library
install(TARGETS parflow_nuopc
  EXPORT ParFlow
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  INCLUDES DESTINATION include
)
install(FILES ${CMAKE_Fortran_MODULE_DIRECTORY}/parflow_nuopc.mod
  DESTINATION include
)

