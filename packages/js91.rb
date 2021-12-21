require 'package'

class Js91 < Package
  description 'Spidermonkey is a javaScript interpreter with libraries from Mozilla — Version 91'
  @_ver = '91.4.1'
  version @_ver
  license 'MPL-2.0'
  compatibility 'all'
  source_url "https://archive.mozilla.org/pub/firefox/releases/#{@_ver}esr/source/firefox-#{@_ver}esr.source.tar.xz"
  source_sha256 '75e98daf53c5aea19d711a625d5d5e6dfdc8335965d3a19567c62f9d2961fc75'

  binary_url({
    x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/js91/91.4.1_x86_64/js91-91.4.1-chromeos-x86_64.tpxz'
  })
  binary_sha256({
    x86_64: '9c0409340ef5882409697eb0fa452fd6267cdc93f535d27dfeb2b8fac43a1b15'
  })

  depends_on 'autoconf213' => :build
  depends_on 'rust' => :build
  depends_on 'llvm' => :build
  depends_on 'nspr'

  @rust_default_host = case ARCH
                       when 'aarch64', 'armv7l'
                         'armv7-unknown-linux-gnueabihf'
                       else
                         "#{ARCH}-unknown-linux-gnu"
                       end

  def self.patch
    # Python 3.10 fixes
    system 'sed -i s,collections.Sequence,collections.abc.Sequence,g python/mozbuild/mozbuild/util.py'
    system "sed -i 's/Iterable, OrderedDict/OrderedDict/' python/mozbuild/mozbuild/backend/configenvironment.py"
    system "sed -i '/from collections import OrderedDict/a from collections.abc import Iterable' python/mozbuild/mozbuild/backend/configenvironment.py"
    system "sed -i 's/collections import defaultdict, MutableSequence/collections import defaultdict/' testing/mozbase/manifestparser/manifestparser/filters.py"
    system "sed -i '/from collections import defaultdict/a from collections.abc import MutableSequence' testing/mozbase/manifestparser/manifestparser/filters.py"
    system "sed -i 's/collections import Iterable/collections.abc import Iterable/' python/mozbuild/mozbuild/makeutil.py"
  end

  def self.build
    @mozconfig = <<~MOZCONFIG_EOF
      ac_add_options --disable-debug
      ac_add_options --disable-debug-symbols
      ac_add_options --disable-jemalloc
      ac_add_options --disable-strip
      ac_add_options --enable-application=js
      ac_add_options --enable-hardening
      ac_add_options --enable-optimize
      ac_add_options --enable-optimize
      ac_add_options --enable-readline
      ac_add_options --enable-release
      ac_add_options --enable-shared-js
      ac_add_options --libdir=#{CREW_LIB_PREFIX}
      ac_add_options --prefix=#{CREW_PREFIX}
      ac_add_options --with-intl-api
      ac_add_options --without-system-icu
      ac_add_options --with-system-nspr
      ac_add_options --with-system-zlib
      mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj
    MOZCONFIG_EOF
    File.write('.mozconfig', @mozconfig)
    unless %w[armv7l aarch64].include?(ARCH)
      open('.mozconfig', 'a') do |f|
        f.puts 'ac_add_options --enable-rust-simd'
      end
    end
    FileUtils.mkdir_p 'obj'
    Dir.chdir 'obj' do
      # error: Cannot set `RUSTC_BOOTSTRAP=1` from build script of `packed_simd v0.3.4 (https://github.com/hsivonen/packed_simd?rev=0917fe780032a6bbb23d71be545f9c1834128d75#0917fe78)`.
      # note: Crates cannot set `RUSTC_BOOTSTRAP` themselves, as doing so would subvert the stability guarantees of Rust for your project.
      # help: If you're sure you want to do this in your project, set the environment variable `RUSTC_BOOTSTRAP=packed_simd` before running cargo instead.
      ENV['RUSTC_BOOTSTRAP'] = 'packed_simd,encoding_rs'
      system "CFLAGS='-fcf-protection=none' \
            CXXFLAGS='-fcf-protection=none' \
            CC=gcc CXX=g++ \
            RUSTFLAGS='-Clto=thin' \
            RUSTUP_HOME='#{CREW_PREFIX}/share/rustup' \
            CARGO_HOME='#{CREW_PREFIX}/share/cargo' \
            LDFLAGS='-lreadline -ltinfo' \
            MACH_USE_SYSTEM_PYTHON=1 \
            MOZCONFIG=../.mozconfig \
            ../mach build"
    end
  end

  def self.install
    Dir.chdir 'obj' do
      system "DESTDIR=#{CREW_DEST_DIR} make install"
      FileUtils.rm Dir.glob("#{CREW_DEST_LIB_PREFIX}/*.ajs")
    end
  end
end
