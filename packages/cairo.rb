require 'package'
  
class Cairo < Package
  description 'Cairo is a 2D graphics library with support for multiple output devices.'
  homepage 'https://www.cairographics.org'
  version '1.17.4'
  compatibility 'all'
  source_url 'https://cairographics.org/snapshots/cairo-1.17.4.tar.xz'
  source_sha256 '74b24c1ed436bbe87499179a3b27c43f4143b8676d8ad237a6fa787401959705'

  binary_url ({
     aarch64: 'https://dl.bintray.com/chromebrew/chromebrew/cairo-1.17.4-chromeos-armv7l.tar.xz',
      armv7l: 'https://dl.bintray.com/chromebrew/chromebrew/cairo-1.17.4-chromeos-armv7l.tar.xz',
        i686: 'https://dl.bintray.com/chromebrew/chromebrew/cairo-1.17.4-chromeos-i686.tar.xz',
      x86_64: 'https://dl.bintray.com/chromebrew/chromebrew/cairo-1.17.4-chromeos-x86_64.tar.xz',
  })
  binary_sha256 ({
     aarch64: '151bc64ba6689b0925e8215ef9b68e00701e157a958f2f3b1f43f92c6c1d034f',
      armv7l: '151bc64ba6689b0925e8215ef9b68e00701e157a958f2f3b1f43f92c6c1d034f',
        i686: 'c2ad484f2a0bb1469da8e5f6611ed04010b3eec59513d2898652e4fae4b6d708',
      x86_64: 'd6e34c83bcdd4b336283381669d9a6aa528ae64a439e65a53d5c21f73a44c27d',
  })

  depends_on 'libpng'
  depends_on 'lzo'
  depends_on 'pixman'
  depends_on 'mesa'
  depends_on 'gperf'

  def self.build
    system "meson #{CREW_MESON_OPTIONS} \
    -Dgl-backend=glesv3 \
    -Dtests=disabled \
    -Dtee=enabled \
    builddir"
    system "meson configure builddir"
    system "ninja -C builddir"
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} ninja -C builddir install"
  end
end
