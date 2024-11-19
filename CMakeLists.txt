cmake_minimum_required(VERSION 3.9)

project(sohun-tpu VERSION 0.1.0)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

find_package(VerilatorBuild)
build_uvm()

add_subdirectory(hdl)
