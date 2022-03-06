# Adapted from Arch Linux containerd PKGBUILD at:
# https://github.com/archlinux/svntogit-community/raw/packages/containerd/trunk/PKGBUILD

require 'package'

class Containerd < Package
  description 'An open and reliable container runtime'
  homepage 'https://containerd.io/'
  version '1.6.1'
  license 'Apache'
  compatibility 'all'
  source_url 'https://github.com/containerd/containerd.git'
  git_hashtag "v#{version}"

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/containerd/1.6.1_armv7l/containerd-1.6.1-chromeos-armv7l.tar.zst',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/containerd/1.6.1_armv7l/containerd-1.6.1-chromeos-armv7l.tar.zst',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/containerd/1.6.1_x86_64/containerd-1.6.1-chromeos-x86_64.tar.zst'
  })
  binary_sha256({
    aarch64: '8836c25633fa7ef919c248783998f2da5f7fdd71823bb639c9e8186cdeace15b',
     armv7l: '8836c25633fa7ef919c248783998f2da5f7fdd71823bb639c9e8186cdeace15b',
     x86_64: '30cb7cb071671835d9083de91cf2873737cde2b1d7448fcc98898156d654d92a'
  })

  depends_on 'docker_systemctl_replacement'
  depends_on 'runc'
  depends_on 'go' => ':build'
  depends_on 'btrfsprogs' => ':build'
  depends_on 'libseccomp' => ':build'
  depends_on 'containers_common' => ':build'
  depends_on 'go_md2man' => ':build'
  no_fhs

  def self.patch
    system "sed -i 's,/sbin,#{CREW_PREFIX}/bin,g' containerd.service"
    system "sed -i 's,/run,/var/run/chrome,g' defaults/defaults_unix.go"
    system "sed -i 's,/var,#{CREW_PREFIX}/var,g' defaults/defaults_unix.go"
    system "sed -i 's,/etc,#{CREW_PREFIX}/etc,g' defaults/defaults_unix.go"
  end

  def self.build
    system "GOFLAGS='-trimpath -mod=readonly -modcacherw' make VERSION=v1.6.1 GO_BUILD_FLAGS='-trimpath -mod=readonly -modcacherw' GO_GCFLAGS= EXTRA_LDFLAGS='-buildid='"
    system "GOFLAGS='-trimpath -mod=readonly -modcacherw' make VERSION=v1.6.1 man"
  end

  def self.install
    FileUtils.mkdir_p %W[
      #{CREW_DEST_PREFIX}/.config/systemd/user
      #{CREW_DEST_MAN_PREFIX}/man5
      #{CREW_DEST_MAN_PREFIX}/man8
    ]
    system "make PREFIX=#{CREW_PREFIX} DESTDIR=#{CREW_DEST_DIR} install"
    FileUtils.install 'containerd.service', "#{CREW_DEST_PREFIX}/.config/systemd/user/containerd.service", mode: 0o644
    FileUtils.install Dir['man/*.5'], "#{CREW_DEST_MAN_PREFIX}/man5", mode: 0o644
    FileUtils.install Dir['man/*.8'], "#{CREW_DEST_MAN_PREFIX}/man8", mode: 0o644
  end
end
