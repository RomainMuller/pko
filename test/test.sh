#!/bin/bash
set -euo pipefail

export ROOT=$PWD # So it's available in sub-shells

##############
### SET-UP ###
##############

dir=$(mktemp -d)
cleanup() {
    cd ${ROOT}
    rm -rf ${dir}
}
trap cleanup EXIT

# Now we'll create a hierarchy, so we can test overlay determination is correct:
#
# ${dir}
# ├─ install
# │  ├─ usr             We'll "npm install" pko here
# │  └─ .pko           This is the install-relative repository
# ├─ cwd
# │  ├─ .pko           This is the $PWD-relative repository
# │  └─ sub             PWD to test the tree crawling of PWD-relative detection
# └─ env
#    └─ repository      This will be the environment-configured repository

install_prefix=${dir}/install/usr
(
    mkdir -p ${install_prefix}
    cd ${install_prefix}
    # Hopping thorugh `npm pack` to avoid `npm`'s local symlinking, that would interfere with install-relative discover
    tarball=$(npm pack --ignore-scripts ${ROOT})
    npm install --no-save @istanbuljs/nyc-config-typescript nyc source-map-support ts-node typescript
    npm install --global-style --no-save ${tarball}
    ln -s node_modules/.bin bin
)

COVERAGE_ROOT="${ROOT}/coverage/integ"

NYC="${install_prefix}/bin/nyc --reporter=lcovonly --cwd=${ROOT}"
PKO="${install_prefix}/bin/pko"

echo '{ "extends": "@istanbuljs/nyc-config-typescript", "all": true }' > ${dir}/.nycrc


mkdir -p ${dir}/install/.pko/install-relative
echo '{"name": "install-relative", "versions": { "1.0.0": {} }}' \
    > ${dir}/install/.pko/install-relative/package.json

mkdir -p ${dir}/cwd/.pko/cwd-relative
echo '{"name": "cwd-relative", "versions": { "1.0.0": {} }}' \
    > ${dir}/cwd/.pko/cwd-relative/package.json
mkdir -p ${dir}/cwd/sub

mkdir -p ${dir}/env/repository/env
echo '{"name": "env", "versions": { "1.0.0": {} }}' \
    > ${dir}/env/repository/env/package.json

unset PKO_REPOSITORY # in case the environment had it

##################
### TEST CASES ###
##################
exit_code=0
export PKO_NO_COLOR=1 # Disable colored output

(
    title="Correctly uses install-relative repository"
    cd ${dir}
    expected="install-relative@1.0.0"
    actual=$(${NYC} --report-dir=${COVERAGE_ROOT}/$(echo $title | sed -e 's/[^A-Za-z0-9_-]/_/g') ${PKO} ls-overrides)
    if [ "${expected}" == "${actual}" ]; then
        echo "✅ ${title}"
    else
        echo "❌ ${title}"
        echo "├─ Expected: ${expected}"
        echo "└─ Actual:   ${actual}"
        exit_code=1
    fi
)

(
    title="Correctly uses \$PWD-relative repository (current directory)"
    cd ${dir}/cwd
    expected="cwd-relative@1.0.0"
    actual=$(${NYC} --report-dir=${COVERAGE_ROOT}/$(echo $title | sed -e 's/[^A-Za-z0-9_-]/_/g') ${PKO} ls-overrides)
    if [ ${expected} == ${actual} ]; then
        echo "✅ ${title}"
    else
        echo "❌ ${title}"
        echo "├─ Expected: ${expected}"
        echo "└─ Actual:   ${actual}"
        exit_code=1
    fi
)

(
    title="Correctly uses \$PWD-relative repository (parent directory)"
    cd ${dir}/cwd/sub
    expected="cwd-relative@1.0.0"
    actual=$(${NYC} --report-dir=${COVERAGE_ROOT}/$(echo $title | sed -e 's/[^A-Za-z0-9_-]/_/g') ${PKO} ls-overrides)
    if [ ${expected} == ${actual} ]; then
        echo "✅ ${title}"
    else
        echo "❌ ${title}"
        echo "├─ Expected: ${expected}"
        echo "└─ Actual:   ${actual}"
        exit_code=1
    fi
)

(
    title="Correctly uses environment-configured repository"
    cd ${dir}
    expected="env@1.0.0"
    actual=$(PKO_REPOSITORY=${dir}/env/repository ${NYC} --report-dir=${COVERAGE_ROOT}/$(echo $title | sed -e 's/[^A-Za-z0-9_-]/_/g') ${PKO} ls-overrides)
    if [ ${expected} == ${actual} ]; then
        echo "✅ ${title}"
    else
        echo "❌ ${title}"
        echo "├─ Expected: ${expected}"
        echo "└─ Actual:   ${actual}"
        exit_code=1
    fi
)

(
    title="Correctly adds published packages to overlay"
    cd ${dir}
    version=$(node -e "console.log(require('${ROOT}/package.json').version);")
    NL=$'\n'
    expected="install-relative@1.0.0${NL}pko@${version}"
    ${NYC} --report-dir=${COVERAGE_ROOT}/$(echo $title | sed -e 's/[^A-Za-z0-9_-]/_/g')-1 ${PKO} publish ${install_prefix}/pko-*.tgz
    actual=$(${NYC} --report-dir=${COVERAGE_ROOT}/$(echo $title | sed -e 's/[^A-Za-z0-9_-]/_/g')-2 ${PKO} ls-overrides)
    if [ "${expected}" == "${actual}" ]; then
        echo "✅ ${title}"
    else
        echo "❌ ${title}"
        echo "├─ Expected: ${expected}"
        echo "└─ Actual:   ${actual}"
        exit_code=1
    fi
)

exit ${exit_code}
