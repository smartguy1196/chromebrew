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
     aarch64: '605fb51877541f644a2cc99e81e42ea81397ecce87eb75652c938a3cda695584',
      armv7l: '605fb51877541f644a2cc99e81e42ea81397ecce87eb75652c938a3cda695584',
        i686: 'cc3f8e9c3879216e866fdf8b32697a252af9541f7296fed5feffb15c402f7371',
      x86_64: 'fc4c042f69ec1a20624679237a30af2e420ae59d3a3a17ee033d210373b02571',
  })

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
      --with-plugindir=#{CREW_LIB_PREFIX}/sudo \
      --with-passprompt=\"[sudo] password for %p: \" \
      --enable-openssl \
      --without-linux-audit \
      --without-opie \
      --with-all-insults \
      --with-exempt=chronos \
      --enable-pie \
      --disable-log-client \
      --with-libpath=#{CREW_LIB_PREFIX}"
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
    
    puts "Settings permissions using system sudo".orange
    system "/usr/bin/sudo chown root:root #{CREW_PREFIX}/bin/sudo"
    system "/usr/bin/sudo chmod u+s #{CREW_PREFIX}/bin/sudo"
    system "/usr/bin/sudo chown root:root #{CREW_LIB_PREFIX}/sudo/sudoers.so"
    
    system "/usr/bin/sudo  #{CREW_PREFIX}/sbin/ldconfig"
  end
end
