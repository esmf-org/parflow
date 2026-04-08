# Run one ESMX integration test.
# Expected variables passed via -D:
#   TEST_NAME: Name of the test
#   TEST_CONFIG: Path to the ESMX configuration file
#   TEST_FILES: List of input files needed to run the test
#   TEST_RUNDIR: Base directory for running ESMX tests
#   ESMX_EXE: Path to the ESMX executable
# Optional variables:
#   MPIEXEC: MPI execution command (e.g., mpirun or srun)
#   MPIEXEC_NUMPROC_FLAG: Flag to specify number of processes
#   MPIEXEC_RANKS: Number of ranks to use for the test
#   MPIEXEC_PREFLAGS: Flags to prepend to the MPI execution command
#   MPIEXEC_POSTFLAGS: Flags to append to the MPI execution command

# Check required variables
if (NOT DEFINED TEST_NAME)
  message(FATAL_ERROR "TEST_NAME is required")
endif()
if (NOT DEFINED TEST_FILES)
  message(FATAL_ERROR "TEST_FILES is required")
endif()
if (NOT DEFINED TEST_RUNDIR)
  message(FATAL_ERROR "TEST_RUNDIR is required")
endif()
if (NOT DEFINED ESMX_EXE)
  message(FATAL_ERROR "ESMX_EXE is required")
endif()

# Check if ESMX executable exists
if (NOT EXISTS "${ESMX_EXE}")
  message(FATAL_ERROR "Unable to locate ESMX executable: ${ESMX_EXE}")
endif()

# Set up run directory for the test
set(run_dir "${TEST_RUNDIR}/${TEST_NAME}")
file(MAKE_DIRECTORY "${run_dir}")
file(COPY ${TEST_FILES} DESTINATION "${run_dir}")

# Construct the execution command
if (DEFINED MPIEXEC AND NOT "${MPIEXEC}" STREQUAL "")
  set(run_command ${MPIEXEC})
  if (NOT DEFINED MPIEXEC_RANKS)
    set(MPIEXEC_RANKS 1)
  endif()
  if (DEFINED MPIEXEC_PREFLAGS AND NOT "${MPIEXEC_PREFLAGS}" STREQUAL "")
    separate_arguments(mpiexec_preflags UNIX_COMMAND "${MPIEXEC_PREFLAGS}")
    list(APPEND run_command ${mpiexec_preflags})
  endif()
  if (DEFINED MPIEXEC_NUMPROC_FLAG AND NOT "${MPIEXEC_NUMPROC_FLAG}" STREQUAL "")
    list(APPEND run_command ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_RANKS})
  endif()
  list(APPEND run_command "${ESMX_EXE}")
  if (DEFINED MPIEXEC_POSTFLAGS AND NOT "${MPIEXEC_POSTFLAGS}" STREQUAL "")
    separate_arguments(mpiexec_postflags UNIX_COMMAND "${MPIEXEC_POSTFLAGS}")
    list(APPEND run_command ${mpiexec_postflags})
  endif()
else()
  set(run_command "${ESMX_EXE}")
endif()

# Execute the ESMX test
message(STATUS "Running ESMX test: ${run_command} ${TEST_CONFIG}")
execute_process(
  COMMAND ${run_command} "${TEST_CONFIG}"
  WORKING_DIRECTORY "${run_dir}"
  RESULT_VARIABLE run_result
)
if (NOT run_result EQUAL 0)
  message(FATAL_ERROR "ESMX test '${TEST_NAME}' failed")
endif()
