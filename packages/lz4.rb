require 'package'

class Lz4 < Package
  description 'LZ4 is lossless compression algorithm, providing compression speed at 400 MB/s per core (0.16 Bytes/cycle).'
  homepage 'https://lz4.github.io/lz4/'
  version '1.9.4'
  license 'BSD-2 and GPL-2'
  compatibility 'all'
  source_url 'https://github.com/lz4/lz4/archive/v1.9.4.tar.gz'
  source_sha256 '0b0e3aa07c8c063ddf40b082bdf7e37a1562bda40a0ff5272957f3e987e0e54b'

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/lz4/1.9.4_armv7l/lz4-1.9.4-chromeos-armv7l.tar.xz',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/lz4/1.9.4_armv7l/lz4-1.9.4-chromeos-armv7l.tar.xz',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/lz4/1.9.4_i686/lz4-1.9.4-chromeos-i686.tar.xz',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/lz4/1.9.4_x86_64/lz4-1.9.4-chromeos-x86_64.tar.xz'
  })
  binary_sha256({
    aarch64: 'a1c108a40d2cd12cd70488029d5e85690714e5184f891bf975d0d0c84577df14',
     armv7l: 'a1c108a40d2cd12cd70488029d5e85690714e5184f891bf975d0d0c84577df14',
       i686: '7f57b3194d7fb0a952cd10213f65749edb5ae622c86ef0f735e2235fe0d019a6',
     x86_64: '63a1a23a609792a65ade4518677b92239994c669a14e051b5735bd8764726e30'
  })

  no_patchelf
  no_zstd

  def self.build
    system 'make', "PREFIX=#{CREW_PREFIX}"
  end

  def self.install
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", "LIBDIR=#{CREW_LIB_PREFIX}", 'install'
  end
end
