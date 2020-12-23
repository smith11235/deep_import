require 'spec_helper'

describe "Timing Example", timing: true do
  it "Normal" do
    make_random_nested_data 
    show_total_records
  end

  it "DeepImport" do
    DeepImport.import(on_save: :noop) do # works
      make_random_nested_data
    end
    show_total_records
  end

  # Sample Code: Can run normally or from DeepImport
  def make_random_nested_data
    limit = (ENV["LIMIT"] || "10").to_i
    (0..limit).each do |parent_number|
      parent = Parent.new 
      parent.save!
      (0..limit).each do |child_number|
        child = parent.children.create!
        (0..limit).each do |grandchild_number|
          grandchild = child.grand_children.create!
        end
      end
    end
  end

  around(:each) do |example|
    type = example.metadata[:description]
    puts "================================="
    puts "Import Starting: #{type}".green
    sdate = DateTime.now
    example.call
    edate = DateTime.now
    dur = ((edate - sdate) * 24 * 60 * 60).to_f.round(2)
    puts "Import Ended: #{type}: #{dur} seconds".green
    puts "================================="
  end

  def show_total_records
    s = {}
    [Parent, Child, GrandChild].each {|m| s[m.to_s] = m.count}
    s["Total Records Loaded"] = s.values.sum
    puts s.to_yaml.gsub("---\n", '').yellow
  end

end