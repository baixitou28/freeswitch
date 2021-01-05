#!/bin/sh
##### -*- mode:shell-script; indent-tabs-mode:nil; sh-basic-offset:2 -*-

sdir="."
[ -n "${0%/*}" ] && sdir="${0%/*}"
. $sdir/common.sh

check_pwd
check_input_ver_build $@
eval $(parse_version "$1")

if [ -n "$rev" ]; then
  dst_name="freeswitch-$cmajor.$cminor.$cmicro.$rev"
else
  dst_name="freeswitch-$cmajor.$cminor.$cmicro"
fi
dst_parent="/tmp/"
dst_dir="/tmp/$dst_name"
release="1"
if [ $# -gt 1 ]; then
  release="$2"
fi

(mkdir -p rpmbuild && cd rpmbuild && mkdir -p SOURCES BUILD BUILDROOT i386 x86_64 SPECS)
#tiger 取src_dist rpm 编译文件spec，和freeswitch*.tar.bz2等 # v8-3.24.14.tar.bz2等fs依赖文件在前面的get_extra_sources.sh已经下载在这个目录里了
cd $src_repo
cp -a src_dist/*.spec rpmbuild/SPECS/ || true
cp -a src_dist/* rpmbuild/SOURCES/ || true
cd rpmbuild/SPECS
set_fs_release "$release"
cd ../../

rpmbuild --define "_topdir %(pwd)/rpmbuild" \
  --define "_rpmdir %{_topdir}" \
  --define "_srcrpmdir %{_topdir}" \
  -ba rpmbuild/SPECS/freeswitch.spec

mkdir -p $src_repo/RPMS
mv $src_repo/rpmbuild/*/*.rpm $src_repo/RPMS/.

cat 1>&2 <<EOF
----------------------------------------------------------------------//tiger 前面脚本get_extra_sources.sh 取freeswitch spec的Source0文件
The v$cver-$build RPMs have been rolled, now we //tiger BUILD shell 这里复制了src_dist/* rpmbuild/SOURCES/(包含了 v8-3.24.14.tar.bz2等) 参考下载目录 /root/freeswitch_1.8.2_build/freeswitch.1.8.2/rpmbuild/BUILD/freeswitch-1.8.2/rpmbuild/SOURCES
just need to push them to the YUM Repo //TIGER  创建 用自定义的目录 来rpmbuild编译 --define "_rpmdir %{_topdir}" 
----------------------------------------------------------------------
EOF

