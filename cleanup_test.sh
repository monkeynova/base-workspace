#!/bin/sh

cd $BUILD_WORKSPACE_DIRECTORY
pwd
find . -name \*.h -o -name \*.cc | xargs clang-format --style=Google -i --dry-run -Werror
if [ $? != 0 ]
then
  echo "C++ files not clean"
  exit 1
fi
find . -name BUILD | xargs buildifier -d --diff_command=diff
if [ $? != 0 ]
then
  echo "BUILD files not clean"
  exit 1
fi
