require "net/ftp"
require "rubygems/package"
require "zlib"
require "fileutils"
require "pry"

namespace :import do
  task openbsd: :environment do
    go_fetch(
      "OpenBSD",
      "ftp.usa.openbsd.org",
      "/pub/OpenBSD/snapshots",
      "ports.tar.gz"
    )
  end

  task freebsd: :environment do
    go_fetch(
      "FreeBSD",
      "ftp.nl.freebsd.org",
      "/pub/FreeBSD/ports/ports",
      "ports.tar.gz"
    )
  end

  task netbsd: :environment do
    go_fetch(
      "NetBSD",
      "ftp.netbsd.org",
      "/pub/pkgsrc/stable",
      "pkgsrc.tar.gz"
    )
  end

  def untar(io, destination)
    Gem::Package::TarReader.new io do |tar|
      tar.each do |tarfile|
        destination_file = File.join destination, tarfile.full_name

        if tarfile.directory?
          FileUtils.mkdir_p destination_file
        else
          destination_directory = File.dirname(destination_file)
          FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)

          puts destination_file

          File.open destination_file, "wb" do |f|
            f.print tarfile.read
          end
        end
      end
    end
  end

  def go_fetch(platform, server, root, tgz)
    # binding.pry

    ftp = Net::FTP.new(server)
    ftp.login
    ftp.chdir(root)

    puts "Downloading #{ tgz } for #{ platform }..."

    ftp.getbinaryfile(tgz)
    ftp.close

    puts "Extracting..."

    # https://gist.github.com/sinisterchipmunk/1335041/5be4e6039d899c9b8cca41869dc6861c8eb71f13
    io = Zlib::GzipReader.open(tgz)
    untar(io, ".")

    # Cleanup folders
    if platform == ["OpenBSD", "NetBSD"]
      FileUtils.rm_rf(Dir.glob("./ports/CVS"))
      FileUtils.rm_rf(Dir.glob("./ports/*/CVS"))
    end

    if platform == "FreeBSD"
      FileUtils.rm_rf(Dir.glob("./ports/Mk"))
      FileUtils.rm_rf(Dir.glob("./ports/Templates"))
      FileUtils.rm_rf(Dir.glob("./ports/Tools"))
    end

    puts "Importing..."

    categories = Dir.glob("./ports/*").each { |category_path|
      if File.directory? category_path
        category = File.basename(category_path)

        new_category = Category.create!(
          name: category,
          platform: Platform.find_by_name(platform)
        )

        if new_category.valid?
          puts "#{ new_category.name } OK"
        end

        # binding.pry

        # Get description, summary and URL
        ports = Dir.glob("#{ category_path }/*").each { |port_path|
          port = File.basename(port_path)

          description = "#{ port_path }/pkg/DESCR"
          build_script = "#{ port_path }/Makefile"

          if File.exist?(description)
            description = File.read(description)
          end

          if File.exist?(build_script)
            summary = File.readlines(build_script).find { |line| line =~ /^COMMENT/ }
            url = File.readlines(build_script).find { |line| line =~ /^HOMEPAGE|^WWW/ }

            if summary
              summary = summary.gsub(/COMMENT=\t/, "")
              summary = summary.rstrip!
            end

            if url
              url = url.gsub(/HOMEPAGE=\t/, "")
              url = url.rstrip!
            end
          end

          # binding.pry

          new_port = Port.create!(
            name: port,
            summary: summary,
            url: url,
            description: description,
            category: Category.find_by_name(category),
            platform: Platform.find_by_name(platform)
          )

          if new_port.valid?
            puts "#{ category_path }/#{ new_port.name } OK"
          end
        }
      end
    }

    # Cleanup
    FileUtils.rm_rf(Dir.glob("./ports*"))

    if platform == "NetBSD"
      FileUtils.rm_rf(Dir.glob("./*.data"))
      FileUtils.rm_rf(Dir.glob("./*.paxheader"))
      FileUtils.rm_rf(Dir.glob("./*.pax_global_header"))
    end
  end
end

