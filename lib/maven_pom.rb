require 'nokogiri'

require "maven_pom/version"
require "maven_pom/error"
require "maven_pom/pom"
require "maven_pom/sorter"

module MavenPom
  def self.all
    @loaded ||= {}
  end

  def self.from(path)
    Pom.new File.read(path), path
  end

  def self.from_url(url)
    Pom.new open(url), url
  end

  def self.from_string(str)
    Pom.new str, str
  end

  def self.sort(poms)
    Sorter.new(poms).sort
  end
end
