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

##### Sanity Checks #####
# BOTTLE_DIR is populated by supported arch machines
if [ -z "$BOTTLE_DIR" ] || ! [ -d "$BOTTLE_DIR" ]; then
    printf "BOTTLE_DIR not set or found.\n"
    exit 1
fi
if [ -z "SERVER_DIR" ] || [ -z "$MID_SERVER" ] || [ -z "$SUPPORTED_ARCHS" ]; then
    printf "Environment not set correctly.\n"
    exit 1
fi
if ! [ -d "Formula" ]; then
    printf "Formula directory not found. This script must be executed while in the homebrew-moose repository.\n"
    exit 1
fi

# Populate supported formulas
FORMULAS=`./get_formulas.py`
exitIfReturnCode $?
printf "Syncing bottles for formulas: ${FORMULAS}\n"

# Loop through supported bottle arches and adjust formula SHAs for each supported formula
# Be sure to error if we do not find a supported arch/bottle pair (something went wrong and
# was not detected earlier)
for ARCH in ${SUPPORTED_ARCHS[@]}; do
    printf "Updating bottles for ${ARCH}\n"
    for FORMULA in ${FORMULAS[@]}; do
        printf "Working on ${FORMULA}...\n"
        if [ -f "$BOTTLE_DIR/${FORMULA}-${ARCH}.md5" ]; then
            SHA=`cat $BOTTLE_DIR/${FORMULA}-${ARCH}.md5 | cut -d\  -f1`
            BOTTLE=`cat $BOTTLE_DIR/${FORMULA}-${ARCH}.md5 | cut -d\  -f3`
        else
            printf "${FORMULA}-${ARCH} bottle not created\n"
            exit 1
        fi

        # Upload bottle to server
        print_and_run ssh -q "${MID_SERVER}" "rsync -razq --no-motd ${BOTTLE_DIR}/${BOTTLE}" "${SERVER_DIR}"
        exitIfReturnCode $?

        # Modify Formula SHAs using in-place sed arguments
        if [ `uname` = "Linux" ]; then
            # Linux sed
            #     \/
            sed -i'' -e "s/sha256.*=> :${ARCH}/sha256 \"${SHA}\" => :${ARCH}/g" Formula/${FORMULA}.rb
        else
            # BSD set
            #     \/
            sed -i '' -e "s/sha256.*=> :${ARCH}/sha256 \"${SHA}\" => :${ARCH}/g" Formula/${FORMULA}.rb
        fi
    done
done
print_and_run git commit -a -m "Updating Bottles/Formulas/SHAs"
exitIfReturnCode $?

# Checkout master and merge devel
print_and_run git checkout master
exitIfReturnCode $?
print_and_run git merge devel
exitIfReturnCode $?

# Update public bottles and formulas
print_and_run git push origin master
exitIfReturnCode $?

# Clean Bottles
for ARCH in ${SUPPORTED_ARCHS[@]}; do
    for FORMULA in ${FORMULAS[@]}; do
        BOTTLE=`cat $BOTTLE_DIR/${FORMULA}-${ARCH}.md5 | cut -d\  -f3`
        if [ -f "${BOTTLE_DIR}/${BOTTLE}" ]; then rm -f "${BOTTLE_DIR}/${BOTTLE}"; fi
        if [ -f "$BOTTLE_DIR/${FORMULA}-${ARCH}.md5" ]; then rm -f "$BOTTLE_DIR/${FORMULA}-${ARCH}.md5"; fi
    done
done
