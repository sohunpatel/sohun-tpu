include(FetchContent)

find_program(VERILATOR verilator)
find_package(verilator)

macro(build_uvm)
    FetchContent_Declare(uvm
        GIT_REPOSITORY https://github.com/antmicro/uvm-verilator.git
        GIT_TAG        origin/current-patches)
    FetchContent_MakeAvailable(uvm)

    set(COMPILE_ARGS -DUVM_NO_DPI -o ${uvm_BINARY_DIR}) --make cmake
    set(EXTRA_ARGS --timescale 1ns/1ps --error-limit 100)
    set(INC_ARGS +incdir+${uvm_SOURCE_DIR}/src)
    set(WARNING_ARGS
        -Wno-lint
        -Wno-style
        -Wno-SYMRSVDWORD
        -Wno-IGNOREDRETURN
        -Wno-CONSTRAINTIGN
        -Wno-ZERODLY)
    set(VERILATOR_ARGS --cc --timing -Mdir ${uvm_BINARY_DIR} ${COMPILE_ARGS} ${EXTRA_ARGS} ${INC_ARGS} ${WARNING_ARGS} ${uvm_SOURCE_DIR}/src/uvm.sv)

    execute_process(
        WORKING_DIRECTORY ${uvm_BINARY_DIR}
        COMMAND ${VERILATOR} ${VERILATOR_ARGS})

    file(GLOB UVM_LIB_SRCS "${uvm_BINARY_DIR}/*.cpp")
    add_library(uvm
        STATIC
        ${UVM_LIB_SRCS})
    target_include_directories(uvm PRIVATE ${VERILATOR_ROOT}/include)
    target_compile_options(uvm PRIVATE -std=c++17)
endmacro()

function(verilate name srcs test)
    set(SRCS ${srcs} ${uvm_SOURCE_DIR}/src/uvm.sv)
    set(INCS ${uvm_SOURCE_DIR}/src)

    set(VDIR ${CMAKE_CURRENT_BINARY_DIR}/vdir)

    set(COMPILE_ARGS -DUVM_NO_DPI --prefix ${name} -o ${name})
    set(EXTRA_ARGS --timescale 1ns/1ps --error-limit 100)
    set(VERILATOR_ARGS --cc --exe --main --timing -Mdir ${VDIR} ${COMPILE_ARGS} ${EXTRA_ARGS} ${srcs})
    set(VERILATOR_COMMAND ${VERILATOR} ${VERILATOR_ARGS})

    set(GEN_MK  ${CMAKE_CURRENT_BINARY_DIR}/${name}.mk)
    set(SIM_EXE ${CMAKE_CURRENT_BINARY_DIR}/${name})

    if (NOT TARGET sim)
        add_custom_target(sim)
    endif()
    if (NOT TARGET verilate)
        add_custom_target(verilate)
    endif()

    set(VARGS_FILE ${VDIR}/vargs.txt)

    if (NOT EXISTS "${VARGS_FILE}")
        set(VERILATOR_OUTDATED ON)
    else()
        file(READ "${VARGS_FILE}" PREVIOUS_VERILATOR_COMMAND)
        if (NOT VERILATOR_COMMAND STREQUAL PREVIOUS_VERILATOR_COMMAND)
            set(VERILATOR_OUTDATED ON)
        endif()
    endif()

    if (VERILATOR_OUTDATED)
        message(STATUS "Executing verilator ...")
        execute_process(
            COMMAND           ${VERILATOR_COMMAND}
            WORKING_DIRECTORY "${VDIR}"
            RESULT_VARIABLE   _VERILATOR_RC
            OUTPUT_VARIABLE   _VERILATOR_OUTPUT
            ERROR_VARIABLE    _VERILATOR_OUTPUT)
        if (_VERILATOR_RC)
            string(REPLACE ";" " " VERILATOR_COMMAND_READABLE)
            message("Verilator command: \"${VERILATOR_COMMAND_READABLE}\"")
            message("Output:\n${_VERILATOR_OUTPUT}")
            message(FATAL_ERROR "Verilator command failed (return code=${_VERILATOR_RC})")
        endif()
    endif()
    file(WRITE "${VARGS_FILE}" "${VERILATOR_COMMAND}")

    add_custom_command(
        OUTPUT  ${GEN_MK}
        COMMAND ${VERILATOR} ${VERILATOR_ARGS}
        DEPENDS ${srcs})
    add_custom_target(verilate_${name} DEPENDS ${GEN_MK})
    add_dependencies(verilate verilate_${name})

    add_custom_command(
        OUTPUT  ${SIM_EXE}
        COMMAND make -f ${GEN_MK} -o ${SIM_EXE}
        DEPENDS ${GEN_MK})
    add_custom_target(${name} 
        ALL
        DEPENDS ${SIM_EXE})

    add_custom_target(sim_${name}
        COMMAND ${SIM_EXE} +UVM_TESTNAME=${test}
        DEPENDS ${SIM_EXE})
    add_dependencies(sim sim_${name})
endfunction()
