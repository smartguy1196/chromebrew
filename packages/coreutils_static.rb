require 'package'

class Coreutils_static < Package
  description 'GNU coreutils built statically with musl'
  homepage 'http://www.gnu.org/software/coreutils/coreutils.html'
  @_ver = '8.32'
  version @_ver
  compatibility 'all'
  source_url "https://ftpmirror.gnu.org/gnu/coreutils/coreutils-#{@_ver}.tar.xz"
  source_sha256 '4458d8de7849df44ccab15e16b1548b285224dbba5f08fac070c1c0e0bcc4cfa'

  binary_url ({
     aarch64: 'https://dl.bintray.com/chromebrew/chromebrew/coreutils_static-8.32-chromeos-armv7l.tar.xz',
      armv7l: 'https://dl.bintray.com/chromebrew/chromebrew/coreutils_static-8.32-chromeos-armv7l.tar.xz',
        i686: 'https://dl.bintray.com/chromebrew/chromebrew/coreutils_static-8.32-chromeos-i686.tar.xz',
      x86_64: 'https://dl.bintray.com/chromebrew/chromebrew/coreutils_static-8.32-chromeos-x86_64.tar.xz',
  })
  binary_sha256 ({
     aarch64: '6e3e42126657b0039fed241b39a98df44e1de35aad8cd2eedfbc9ef86a7b3436',
      armv7l: '6e3e42126657b0039fed241b39a98df44e1de35aad8cd2eedfbc9ef86a7b3436',
        i686: 'd1a7b5f3511aad8e4d42ea89b8bc9128d5d7cd99b10829ebc8d94681aaf46f51',
      x86_64: 'c485e43b13d8ee7c615329344a4c073130ee7bf1d8ff3eaa029b8dcfc38307cc',
  })

  @musl_version = '1.2.2'
  
  def self.build
  # static build script modified from https://github.com/luciusmagn/coreutils-static/blob/master/build.sh
system "cat <<'EOF'> build.sh
#!/bin/bash
#
# build static coreutils because we need exercises in minimalism
# MIT licensed: google it or see robxu9.mit-license.org.
#
# For Linux, also builds musl for truly static linking.

coreutils_version='#{@_ver}'
musl_version='#{@musl_version}'

platform=$(uname -s)

if [ -d build ]; then
  echo '= removing previous build directory'
  rm -rf build
fi

#mkdir build # make build directory
#pushd build

# download tarballs
#echo '= downloading coreutils'
#curl -LO https://ftpmirror.gnu.org/gnu/coreutils/coreutils-${coreutils_version}.tar.xz

#echo '= extracting coreutils'
#tar xJf coreutils-${coreutils_version}.tar.xz

if [ \"$platform\" = \"Linux\" ]; then
  echo '= downloading musl'
  curl -LO https://www.musl-libc.org/releases/musl-${musl_version}.tar.gz

  echo '= extracting musl'
  tar -xf musl-${musl_version}.tar.gz

  echo '= building musl'
  working_dir=$(pwd)

  install_dir=${working_dir}/musl-install

  pushd musl-${musl_version}
  env CFLAGS=\"$CFLAGS -Os -ffunction-sections -fdata-sections -fPIC\" LDFLAGS=\'-Wl,--gc-sections\' ./configure --prefix=${install_dir}
  echo 'obj/ldso/dlstart.lo: CFLAGS += -fno-lto' >> config.mak
  make install
  popd # musl-${musl-version}

  echo \"= setting CC to musl-gcc\"
  export CC=${working_dir}/musl-install/bin/musl-gcc
  export CFLAGS=\"-static\"
else
  echo '= WARNING: your platform does not support static binaries.'
  echo '= (This is mainly due to non-static libc availability.)'
fi

echo '= building coreutils'

#pushd coreutils-${coreutils_version}
env FORCE_UNSAFE_CONFIGURE=1 CFLAGS=\"$CFLAGS -Os -ffunction-sections -fdata-sections -fPIC\" LDFLAGS=\'-Wl,--gc-sections\' ./configure
make
#popd # coreutils-${coreutils_version}

popd # build

if [ ! -d releases ]; then
  mkdir releases
fi

echo '= strip'
strip -s -R .comment -R .gnu.version --strip-unneeded build/coreutils-${coreutils_version}/coreutils
#echo '= compressing'

shopt -s extglob
# upx currently breaks the binaries
#for file in build/coreutils-${coreutils_version}/src/!(*.*)
#do
#	upx --ultra-brute $file
#done
echo \"= extracting coreutils binary\"
cp src/!(*.*) releases
echo '= done'
EOF"
    system 'chmod +x ./build.sh'
    system './build.sh'
    system 'curl -Lf https://salsa.debian.org/debian/debianutils/-/raw/master/which?inline=false > releases/which && chmod +x releases/which'
    system "sed -i 's /bin/sh,#{CREW_PREFIX}/bin/sh,g' releases/which"

  end

  def self.install
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/bin"
    FileUtils.cd("#{CREW_DEST_PREFIX}/bin") do
      system "echo '#!/bin/bash' > arch"
      system "echo '#{ARCH}' >> arch"
      system 'chmod +x arch'
    end
    FileUtils.cp Dir.glob('releases/*'),"#{CREW_DEST_PREFIX}/bin/"
  end
end
