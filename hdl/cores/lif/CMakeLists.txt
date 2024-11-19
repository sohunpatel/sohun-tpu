find_package(VerilatorBuild)

set(SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/hdl/lif.sv
    ${CMAKE_CURRENT_SOURCE_DIR}/hdl/tbench_top.sv)

verilate(lif_tb ${SOURCES} "lif_test")
