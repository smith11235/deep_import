namespace :example do

  desc "Load sample data with standard ORM calls"
  task normal: :environment do
    report("Normal") do
      make_random_nested_data 
    end
  end
  
  desc "Load sample data with deep import handling"
  task deep_import: :environment do
    report("Deep") do 
      #DeepImport.import do # expect error
      DeepImport.import(on_save: :noop) do # works
        make_random_nested_data
      end
    end
  end

  # Sample Code: Can run as standard, or within deep import
  def make_random_nested_data
    limit = (ENV["LIMIT"] || "10").to_i
    (0..limit).each do |parent_number|
      parent = Parent.new name: SecureRandom.hex
      parent.save # Note: save calls for the 'normal' example, ignored by deep import
      (0..limit).each do |child_number|
        child = parent.children.build name: SecureRandom.hex
        child.save
        (0..limit).each do |grandchild_number|
          grandchild = child.grand_children.build name: SecureRandom.hex 
          grandchild.save
        end
      end
    end
  end

  def report(type)
    # while deep import provides stats, this is for helpful comparison between 'normal' and deep import
    s = stats
    sdate = DateTime.now
    yield # run make data - w/ and w/out deep import
    edate = DateTime.now
    dur = ((edate - sdate) * 24 * 60 * 60).to_f.round(2)
    added(s)
    puts "Import: \"#{type}\": #{dur} seconds".green
  end

  def models
    [Parent, Child, GrandChild]
  end

  def stats
    s = {}
    models.each {|m| s[m] = m.count}
    s
  end

  def added(s)
    puts "Added model instances\n-------------------".yellow
    s.each do |m, init|
      puts "#{m}: #{m.count - init}".yellow
    end
  end
end
