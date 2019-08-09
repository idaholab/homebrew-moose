#!/bin/bash
function exitIfReturnCode()
{
  if [ "$1" != "0" ]; then
    echo "ERROR: exiting with code $1"
    exit $1
  fi
}
function print_cmd()
{
  local p="$PWD/"
  local b="$BUILD_ROOT/"
  local cwd=${p/#$b/BUILD_ROOT/}
  # Use terminal color codes. 33 is yellow. 32 is green
  printf "\e[33m$cwd\e[0m: \e[32m$*\e[0m\n"
}

function print_and_run()
{
  print_cmd $*
  "$@"
}

##### Sanity checks #####
if ! [ "`which brew`" = "/usr/local/bin/brew" ]; then
    printf "Homebrew not found in expected location\n"
    exit 1
fi
if ! [ -d "Formula" ]; then
    printf "Formula directory not found. This script must be executed while in the homebrew-moose repository.\n"
    exit 1
fi
if [ -z "$BOTTLE_STORAGE" ]; then
    printf "Unknown BOTTLE_STORAGE location\n"
    exit 1
fi

# Get a topological sort of formulas we need to build
FORMULAS=`./get_formulas.py`
exitIfReturnCode $?

printf "Building Bottles: $FORMULAS\n"

# Get a topological reverse sort of formulas we need to uninstall
REVERSE_FORMULAS=`./get_formulas.py --reverse`
exitIfReturnCode $?

# Figure out our arch type
SYS_VER=`uname -r | cut -d. -f1`
if [ $SYS_VER = 18 ]; then
    ARCH=mojave
elif [ $SYS_VER = 17 ]; then
    ARCH=high_sierra
elif [ $SYS_VER = 16 ]; then
    ARCH=sierra
else
    printf "Unsupported platform"
    exit 1
fi

# Clean caches
print_and_run brew cleanup -s

# Destroy any bottles already in existence.
print_and_run git clean -xfd

### CAVEATS
### Unfortunately, we can not build a bottle without a tap. And, homebrew will checkout the default branch set forth by github.
### This means we need to separate things while we do our CI work. This is due to the very formula being tested also contains
### the SHA we-do-not-know-yet for each bottle being built.

printf "Uninstall any moose related brews (errors of missing kegs/formulas are okay)\n\n"
for FORMULA in ${REVERSE_FORMULAS[@]}; do
    print_and_run brew uninstall $FORMULA
done

# Remove previous tap
print_and_run rm -rf /usr/local/Homebrew/Library/Taps/idaholab

# Tap current checked out branch (which should be our PR at the time)
print_and_run brew tap idaholab/moose `pwd`
exitIfReturnCode $?

# Build and Bottle each moose related formula
for FORMULA in ${FORMULAS[@]}; do
    print_and_run brew install --build-bottle ${FORMULA}
    if [ $? -ne 0 ]; then
        printf "There was an error building bottle: $FORMULA"
        exitIfReturnCode 1
    fi
    print_and_run brew bottle --root-url="https://mooseframework.org/source_packages" --no-rebuild ${FORMULA}
    exitIfReturnCode $?

    # Unfortunately, brew bottle creates a file name with an extra dash in the name
    print_and_run mv ${FORMULA}--* $(echo ${FORMULA}--* | sed -e "s/${FORMULA}-/${FORMULA}/g")
    exitIfReturnCode $?

    shasum -a 256 ${FORMULA}-* > ${FORMULA}-${ARCH}.md5
    exitIfReturnCode $?

    BOTTLE_SHA="`cat ${FORMULA}-${ARCH}.md5 | cut -d\  -f 1`"
    BOTTLE_NAME="`cat ${FORMULA}-${ARCH}.md5 | cut -d\  -f 3`"

    printf "${BOTTLE_SHA}, ${BOTTLE_NAME}\n"
    # Copy the bottle to rod for redistribution
    print_and_run scp $BOTTLE_NAME $BOTTLE_STORAGE/
    print_and_run scp ${FORMULA}-${ARCH}.md5 $BOTTLE_STORAGE/
    print_and_run rm -f $BOTTLE_NAME ${FORMULA}-${ARCH}.md5
done
