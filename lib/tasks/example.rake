namespace :example do
  # Sample Code 
  # Can be used as standard ORM loading, or with deep import
  # Note: could remove the save calls for a simpler bulk import code block
  def make_data
    limit = (ENV["limit"] || "10").to_i
    (0..limit).each do |parent_number|
      parent = Parent.new name: SecureRandom.hex
      parent.save # Note: save could be left out when deep importing, used to show duality of code
      (0..limit).each do |child_number|
        child = Child.new name: SecureRandom.hex, parent: parent
        child.save
        (0..limit).each do |grandchild_number|
          grandchild = GrandChild.new name: SecureRandom.hex 
          grandchild.child = child 
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
    puts "#{type} Import: Time: #{dur} seconds".green
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
    puts "Added model instances\n-------------------".green
    s.each do |m, init|
      puts "#{m}: #{m.count - init}".green
    end
  end

  desc "Load sample data with standard ORM calls"
  task normal: :environment do
    report("Normal") do
      make_data 
    end
  end
  
  desc "Load sample data with deep import handling"
  task deep_import: :environment do
    report("Deep") do 
      DeepImport.import(on_save: :noop) do # allows same code execution
        make_data
      end
    end
  end
end
