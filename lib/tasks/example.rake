namespace :example do
  # Sample code that could be standard ORM - or deep import
  def make_data
    limit = ENV["limit"] || 10
    (0..limit).each do |parent_number|
      parent = Parent.new name: SecureRandom.hex
      parent.save
      (0..limit).each do |child_number|
        child = Child.new name: SecureRandom.hex
        child.parent = parent # TODO: make it so ^ parent: parent works
        child.save
        (0..limit).each do |grandchild_number|
          grandchild = GrandChild.new name: SecureRandom.hex # TODO: make it so child: child works
          grandchild.child = child
          grandchild.save
        end
      end
    end
  end

  def report(type)
    # deep import provides stats, this is for helpful comparison
    s = stats
    sdate = DateTime.now
    yield # run make data - w/ and w/out deep import
    edate = DateTime.now
    dur = ((edate - sdate) * 24 * 60 * 60).to_i
    added(s)
    puts "#{type} Import: #{dur} seconds".green
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
