require 'spec_helper'

module MavenPom
  describe Pom do
    let(:pom_module) { Pom.new fixture("pom.xml"), "some/pom/path/pom.xml" }
    let(:war_module) { Pom.new fixture("war.xml"), "some/war/path/pom.xml" }
    let(:child_module) { Pom.new fixture("child.xml"), "some/child/path/pom.xml" }

    it "knows the module's packaging" do
      pom_module.packaging.should == 'pom'
      war_module.packaging.should == 'war'
    end

    it "excludes exclusions from dependencies" do

    end

    it "knows the module's dependencies" do
      pom_module.dependencies.each do |d|
         puts d.class
      end
      pom_module.dependencies.should include 'com.example:example-dep-1:4.0'
                                      #   '${project.groupId}:example-dep-2:4.0']
    end

    it "knows the module's parent" do
      child_module.parent.should == pom_module.gav
      child_module.parent_pom.should == pom_module
    end

    it "knows the module's scm url" do
      pom_module.url.should == 'scm:svn:svn+ssh://svn.clownfart.com/opt/svnroot/main/core/trunk'
    end

    it "knows the module's build plugins" do
      child_module.build_plugins.should == %w(
        org.apache.maven.plugins:maven-source-plugin
        org.apache.maven.plugins:maven-javadoc-plugin
        org.apache.maven.plugins:maven-deploy-plugin)
    end

    it "knows the group_id and artifact_id" do
      war_module.group_id.should == "com.example"
      war_module.artifact_id.should == "example-war"
    end

    it "finds the parent's group_id if none is specified" do
      child_module.group_id.should == "com.example"
      child_module.artifact_id.should == "child"
    end

    it "has a gav" do
      war_module.gav.should == "com.example:example-war"
    end

    it "can get the pom's properties" do
      pom_module.properties.should == {'version.jdk' => '1.7'}
    end
  end
end
