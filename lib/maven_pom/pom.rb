module MavenPom
  class Pom
    attr_reader :uri

    def initialize(str, uri)
      @pom = Nokogiri.XML(str)
      @uri = uri

      MavenPom.all[gav] = self
    end

    def as_json(opts = nil)
      {
        :gav       => gav,
        :name      => name,
        :parent    => parent,
        :packaging => packaging
      }
    end

    def to_json(*args)
      as_json.to_json(*args)
    end

    def inspect
      "#<MavenPom::Pom:0x%x gav=%s artifact=%s parent=%s version=%s>>" % [object_id << 1, gav.inspect, artifact_id.inspect, parent.inspect, version.inspect]
    end

    def packaging
      @pom.css("project > packaging").text
    end

    def name
      @pom.css("project > name").text.strip
    end

    def version
      @pom.css("project > version").text.strip
    end

    def developers
      @pom.css("developers > developer").map do |node|
        node.css("email").text
      end
    end

    def build_plugins
      @pom.css("plugins > plugin").map do |node|
        dependency_name_from(node)
      end
    end

    def url
      @pom.css("scm > developerConnection").text.strip
    end

    def parent
      parent = @pom.css("project > parent").first

      if parent
        gid = parent.css("groupId").text
        aid = parent.css("artifactId").text
        v   = parent.css("version").text

        "#{gid}:#{aid}:#{v}"
      end
    end

    def group_id
      gid = @pom.css("project > groupId").text
      gid = @pom.css("project > parent > groupId").text if gid.empty?

      if gid.empty?
        raise MissingGroupIdError, "could not find groupId in pom (uri=#{uri.inspect})"
      end

      gid
    end

    def parent_pom
      MavenPom.all[parent]
    end

    def artifact_id
      @pom.css("project > artifactId").text
    end

    def gav
      @gav ||= "#{group_id}:#{artifact_id}:#{version}"
    end

    def dependencies
      @pom.css("dependencies > dependency").map do |node|
        node.css("exclusions").remove
        Dependency.new(
            node.css("groupId").text,
            node.css("artifactId").text,
            node.css("version").text
        )
      end

    end

    def properties
      props = {}

      @pom.css("project > properties > *").each do |element|
        props[element.name] = element.inner_text
      end

      props
    end

    def dependency_name_from(node)
    gid = node.css("groupId").text
    aid = node.css("artifactId").text
    v   = node.css("version").text

    gid = group_id if gid == "${project.groupId}" # ugh

    "#{gid}:#{aid}:#{v}"

    end

    def modules
      @pom.css("modules > module").map do |node|
        node.text
      end
    end

    def snapshot_dependencies
      dependencies.each.select {|dep| dep.version.include?('SNAP')}
    end

    def multimodule?
      if not modules.empty?
        true
      else
        false
      end
    end

    def dependency(regex)

    end

  end # Pom

  class Dependency
    attr_reader :group,:artifact,:version

    def initialize(g,a,v)
      @group = g #project_group_id if g == "${project.groupId}" # ugh
      @artifact = a
      @version = v #project_version if v == "${project.version}" # ugh
    end

    #def group
    #  if @group.eql?('${project.groupId}')
    #    super(group_id)
    #  end
    #end

    def to_s
      "#{@group}:#{@artifact}:#{@version}"
    end

  end
end # end MavenPom
