# Adapted from Arch Linux pixz PKGBUILD at:
# https://github.com/archlinux/svntogit-community/raw/packages/pixz/trunk/PKGBUILD

require 'package'

class Pixz < Package
  description 'Parallel, indexed xz compressor'
  homepage 'https://github.com/vasi/pixz'
  version '1.0.7-0829'
  compatibility 'all'
  license 'BSD'
  source_url 'https://github.com/vasi/pixz.git'
  git_hashtag '0829c7315c804a4e40abd63a9d624194dc1e4f0a'

  binary_url({

    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/pixz/1.0.7-0829_armv7l/pixz-1.0.7-0829-chromeos-armv7l.tar.xz',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/pixz/1.0.7-0829_armv7l/pixz-1.0.7-0829-chromeos-armv7l.tar.xz',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/pixz/1.0.7-0829_i686/pixz-1.0.7-0829-chromeos-i686.tar.xz',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/pixz/1.0.7-0829_x86_64/pixz-1.0.7-0829-chromeos-x86_64.tar.xz'
  })
  binary_sha256({
    aarch64: 'd5f6b88daa7d17c90a4dbda045641ac269aef5702c29ab4781cd19041d02a089',
     armv7l: 'd5f6b88daa7d17c90a4dbda045641ac269aef5702c29ab4781cd19041d02a089',
       i686: 'ae7555048502a018fb8eeeb26300b10d3916762eb8e730618abe62163d4d0f63',
     x86_64: '4f1ea234835736b20633bea3dca327eadeb225ee9e979db6a0dd86e497133065'
  })

  depends_on 'libarchive'
  depends_on 'asciidoc' => ':build'

  def self.build
    system '[ -x configure ] || ./autogen.sh'
    system "#{CREW_ENV_OPTIONS} \
      manpage=true \
      ./configure #{CREW_OPTIONS}"
    system 'make'
  end

  def self.install
    system "make DESTDIR=#{CREW_DEST_DIR} install"
  end
end
