
cmake_minimum_required(VERSION 2.8)

project(demo_matrix)

find_package(OpenCV REQUIRED)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pipe -std=c++11" CACHE string "" FORCE)
include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

############################################################################ 

set(sources main.cpp)
add_library(demo_matrix SHARED ${sources})
target_link_libraries(demo_matrix ${OpenCV_LIBS})

