cmake_minimum_required(VERSION 3.14)

project(hello LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_library(add_lib src/add.cpp)
target_include_directories(add_lib PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/src")

add_executable(hello src/main.cpp)
target_link_libraries(hello PRIVATE add_lib)

include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
FetchContent_MakeAvailable(googletest)

enable_testing()
include(GoogleTest)

add_executable(basic_addition_test tests/test_basic.cpp)
target_link_libraries(basic_addition_test PRIVATE add_lib GTest::gtest_main)
gtest_discover_tests(basic_addition_test)
