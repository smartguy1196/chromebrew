# Based upon https://source.chromium.org/chromiumos/chromiumos/codesearch/+/main:src/third_party/portage-stable/app-admin/sudo/sudo-1.8.31.ebuild

require 'package'

class Sudo < Package
  description 'Give certain users the ability to run some commands as root'
  homepage 'https://www.sudo.ws/sudo/'
  @_ver = '1.9.5p2'
  version @_ver
  compatibility 'all'
  source_url "https://www.sudo.ws/sudo/dist/sudo-#{@_ver}.tar.gz"
  source_sha256 '539e2ef43c8a55026697fb0474ab6a925a11206b5aa58710cb42a0e1c81f0978'

  binary_url ({
     aarch64: 'https://dl.bintray.com/chromebrew/chromebrew/sudo-1.9.5p2-chromeos-armv7l.tar.xz',
      armv7l: 'https://dl.bintray.com/chromebrew/chromebrew/sudo-1.9.5p2-chromeos-armv7l.tar.xz',
        i686: 'https://dl.bintray.com/chromebrew/chromebrew/sudo-1.9.5p2-chromeos-i686.tar.xz',
      x86_64: 'https://dl.bintray.com/chromebrew/chromebrew/sudo-1.9.5p2-chromeos-x86_64.tar.xz',
  })
  binary_sha256 ({
     aarch64: '698a8d5386d111cc2697bffb06f1d832b894cb4ba2c5b8bb23517d2e91c2fbb0',
      armv7l: '698a8d5386d111cc2697bffb06f1d832b894cb4ba2c5b8bb23517d2e91c2fbb0',
        i686: '12a13e98965e11f8b10fae06027f7d398472cfa631160853e52d6ca30bb49fb3',
      x86_64: '9b3f986086bed5f55d58061098d6f18e7e7795d0cfe41062cb795529d1a01d8f',
  })

  depends_on 'openldap'

  def self.patch
    system "sed -i \"s/CHMODIT=true/CHMODIT=false/g\" install-sh"
    system "sed -i \"s/CHOWNIT=true/CHOWNIT=false/g\" install-sh"
    system "sed -i \"s/CHGRPIT=true/CHGRPIT=t/g\" install-sh"
    system "sed -i \"s/CHGRP=chgrp/CHGRP=true/g\" install-sh"
  end
  
  def self.build
    system "env CFLAGS='-pipe -flto=auto' CXXFLAGS='-pipe -flto=auto' LDFLAGS='-Wno-error=lto-type-mismatch -flto=auto' \
      ./configure #{CREW_OPTIONS} \
      --with-rundir=/run/sudo \
      --with-vardir=/var/db/sudo \
      --with-logfac=auth \
      --enable-gcrypt \
      --with-pam \
      --with-sssd \
      --with-ldap \
      --with-ldap-conf-file=/etc/ldap.conf.sudo \
      --enable-tmpfiles.d=/usr/lib/tmpfiles.d \
      --with-editor=/usr/libexec/editor \
      --with-env-editor \
      --with-plugindir=/usr/lib#{CREW_LIB_SUFFIX}/sudo \
      --with-passprompt=\"[sudo] password for %p: \" \
      --enable-openssl \
      --without-linux-audit \
      --without-opie \
      --with-all-insults \
      --with-exempt=chronos \
      --enable-pie \
      --disable-log-client"
    system "make"
  end
  
  def self.install
    system "make DESTDIR=#{CREW_DEST_DIR} install"
  end
  
  def self.preinstall
    # Change permissions of Chromebrew sudo to allow it to be overwritten
    
    # FileUtils.chown 'chronos, 'chronos', "#{CREW_PREFIX}/bin/sudo"
    # Use System sudo to change permissions since above won't work.
    if File.exist? "#{CREW_PREFIX}/bin/sudo"
      system "/usr/bin/sudo chown chronos:chronos #{CREW_PREFIX}/bin/sudo"
    end
  end
  
  def self.postinstall
    # Do chown here so we don't clutter up DESTDIR
    
    # FileUtils.chown 'root', 'root', "#{CREW_PREFIX}/bin/sudo"
    
    # Use System sudo to change permissions since above gives this error:
    # Performing post-install...
    # /usr/local/lib64/ruby/3.0.0/fileutils.rb:1355:in `chown': Operation not permitted @ apply2files - /usr/local/bin/sudo (Errno::EPERM)
    
    puts "Settings permissions of #{CREW_PREFIX}/bin/sudo using system sudo".orange
    system "/usr/bin/sudo chown root:root #{CREW_PREFIX}/bin/sudo && /usr/bin/sudo chmod u+s #{CREW_PREFIX}/bin/sudo"
  end
end
