require 'spec_helper'

descibe "Importable" do
  it "responds to after initialize"
  it "prepends Saveable module"

  describe "allow_commit?" do
    it "true" 
    it "false"
    it "error"
  end

  describe "normal execution" do
    it "ignores tracking"
    it "allows saves"
  end

  describe "import execution" do
    it "tracks model from initialization"
    it "blocks saves by default"
    it "ignores saves if option set"
  end
end
