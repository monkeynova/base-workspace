#!/bin/sh -x

cd $BUILD_WORKSPACE_DIRECTORY
pwd
find . -name \*.h -o -name \*.cc | xargs clang-format --style=Google -i
find . -name BUILD | xargs buildifier
