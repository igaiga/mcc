# coding: utf-8

require 'tempfile'
require 'fileutils'

module MCC
  RE = /^#.*coding.*:.*$/

  def self.run(files, format = '# coding: utf-8')
    files.each do |file|
      unless include_magick_comment?(file)
        insert_magick_comment(file, format)
      end
    end
  end

  def self.include_magick_comment?(file)
    File.open(file) do |f|
      2.times do
        f.readline =~ RE and return true
      end
    end
    false
  end

  def self.insert_magick_comment(file, magick_comment)
    include_shebang = include_shebang?(file)

    tmp = Tempfile.open(File.basename(file))
    File.open(file) do |f|
      tmp.puts f.readline if include_shebang
      tmp.puts magick_comment

      f.each do |line|
        tmp.puts line
      end
    end
    tmp.flush

    FileUtils.cp(tmp, file)
  ensure
    tmp.close
  end

  def self.include_shebang?(file)
    File.open(file) do |f|
      return !!(f.readline  =~ /^#!/)
    end
  end
end
