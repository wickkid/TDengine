#!/bin/bash
#
# Generate rpm package for centos 

#set -e
#set -x

#curr_dir=$(pwd)
compile_dir=$1
output_dir=$2
tdengine_ver=$3
armver=$4

script_dir="$(dirname $(readlink -f $0))"
top_dir="$(readlink -f ${script_dir}/../..)"
pkg_dir="${top_dir}/rpmworkroom"
spec_file="${script_dir}/tdengine.spec"

#echo "curr_dir: ${curr_dir}"
#echo "top_dir: ${top_dir}"
#echo "script_dir: ${script_dir}"
echo "compile_dir: ${compile_dir}"
echo "pkg_dir: ${pkg_dir}"
echo "spec_file: ${spec_file}"

csudo=""
if command -v sudo > /dev/null; then
    csudo="sudo"
fi

function cp_rpm_package() {
local cur_dir
cd $1
cur_dir=$(pwd)

for dirlist in $(ls ${cur_dir}); do
  if test -d ${dirlist}; then
    cd ${dirlist}
    cp_rpm_package ${cur_dir}/${dirlist}
    cd ..
  fi
  if test -e ${dirlist}; then
    cp ${cur_dir}/${dirlist} ${output_dir}/TDengine-${tdengine_ver}.rpm
  fi
done
}

if [ -d ${pkg_dir} ]; then
  ${csudo} rm -rf ${pkg_dir}
fi
${csudo} mkdir -p ${pkg_dir}
cd ${pkg_dir}

${csudo} mkdir -p BUILD BUILDROOT RPMS SOURCES SPECS SRPMS

${csudo} rpmbuild --define="_version ${tdengine_ver}" --define="_topdir ${pkg_dir}" --define="_compiledir ${compile_dir}" -bb ${spec_file}

# copy rpm package to output_dir, then clean temp dir
#${csudo} cp -rf RPMS/* ${output_dir}
cp_rpm_package ${pkg_dir}/RPMS 

if [ "$armver" == "arm64" ]; then
  mv ${output_dir}/TDengine-${tdengine_ver}.rpm ${output_dir}/TDengine-${tdengine_ver}-arm64.rpm
elif [ "$armver" == "arm32" ]; then
  mv ${output_dir}/TDengine-${tdengine_ver}.rpm ${output_dir}/TDengine-${tdengine_ver}-arm32.rpm
fi

cd ..
${csudo} rm -rf ${pkg_dir}
