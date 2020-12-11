require 'spec_helper'

descibe "BelongsTo" do
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
