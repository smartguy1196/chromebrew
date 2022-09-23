require 'package'

class Vulkan_headers < Package
  description 'Vulkan header files'
  homepage 'https://github.com/KhronosGroup/Vulkan-Headers'
  @_ver = '1.3.229'
  version @_ver
  license 'Apache-2.0'
  compatibility 'all'
  source_url 'https://github.com/KhronosGroup/Vulkan-Headers.git'
  git_hashtag "v#{@_ver}"

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/vulkan_headers/1.3.229_armv7l/vulkan_headers-1.3.229-chromeos-armv7l.tar.zst',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/vulkan_headers/1.3.229_armv7l/vulkan_headers-1.3.229-chromeos-armv7l.tar.zst',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/vulkan_headers/1.3.229_i686/vulkan_headers-1.3.229-chromeos-i686.tar.zst',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/vulkan_headers/1.3.229_x86_64/vulkan_headers-1.3.229-chromeos-x86_64.tar.zst'
  })
  binary_sha256({
    aarch64: 'da4e70de5956a0fb42cabb2600a510da01d68100aae0a10ea03bceff25f740a0',
     armv7l: 'da4e70de5956a0fb42cabb2600a510da01d68100aae0a10ea03bceff25f740a0',
       i686: 'f96c726b742626f4fcdb8c63ecf7a43ded58cbeef331e7a293873524cb284146',
     x86_64: 'a19456ce3200cfae66bc7ea573a4054d9a3da25a291a3cf88a27234c6de9b72e'
  })

  def self.build
    Dir.mkdir 'builddir'
    Dir.chdir 'builddir' do
      system "cmake \
        -G Ninja \
        #{CREW_CMAKE_OPTIONS} \
        .."
    end
    system 'mold -run samu -C builddir'
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} samu -C builddir install"
  end
end
