cmake_minimum_required(VERSION 4.2)
project(photomap)

set(CMAKE_CXX_STANDARD 17)

enable_language(OBJCXX)
set(CMAKE_OBJCXX_STANDARD 17)

add_executable(photomap main.mm)

target_link_libraries(photomap
    "-framework Foundation"
    "-framework Photos"
    "-framework CoreLocation"
)
