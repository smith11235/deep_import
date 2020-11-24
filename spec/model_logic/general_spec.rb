require 'spec_helper'

describe 'DeepImport::ModelLogic (on Child)' do
  describe "DeepImport Module Includes" do

    it "includes ModelLogic" do
      # TODO: change to Importable
      expect(Child.included_modules.include?(DeepImport::ModelLogic)).to be true
      expect(Child.included_modules.include?(DeepImport::ModelLogic::Saveable)).to be true
    end
    it "includes BelongsTo" do
      expect(Child.included_modules.include?(DeepImport::ModelLogic::BelongsTo)).to be true
    end
    it "includes HasMany" do
      pending("test proxy association for extended module")
      expect(Child.included_modules.include?(DeepImport::ModelLogic::HasMany)).to be true
    end

  	describe "Importable enhancements" do
  		it "has accessible deep_import_id" do
  			expect(Child.column_names.include?('deep_import_id')).to be true
  		end
  		it "has after_initialize callback" do
        expect_any_instance_of(Child).to receive(:deep_import_after_initialize)
  		  Child.new
  		end
  		it "adds deep_import_id" do
        expect(Child.new.deep_import_id).to be nil # doesnt if not importing
        DeepImport.import do
          expect(Child.new.deep_import_id).to be_present
        end
        expect(Child.count).to eq(1)
      end
  	end
  end

  describe "Saveable" do
    # TODO: call initialize
    it "allows normal calls outside import" do
      c = Child.new
      c.save
      expect(c.id).to be_present
      c = Child.new
      c.save!
      expect(c.id).to be_present
    end
    describe "while importing" do
      it "blocks save calls by default" do
        expect { 
          DeepImport.import do 
            Child.new.save 
          end
        }.to raise_error

        expect { 
          DeepImport.import do 
            Child.new.save! 
          end
        }.to raise_error

        expect(Child.count).to eq(0)
      end
      it "no-ops save calls with option" do
        DeepImport.import reset: true, on_save: :noop do 
          expect { Child.new.save }.to_not raise_error
          expect { Child.new.save! }.to_not raise_error
          expect(Child.count).to eq(0)
        end
        expect(Child.count).to eq(2)
      end
    end
  end

  describe "Belongs To" do
    it "creates normally if not importing" do
      ['', '!'].each do |ending|
        child = Child.new
        child.save!
        child.send("create_parent#{ending}")
      end
      expect(Parent.count).to eq(2)
    end

    describe "import" do
      it "builds" do
        DeepImport.import do 
          c = Child.new 
          c.build_parent
        end
        expect(Child.count).to eq(1)
        expect(Parent.count).to eq(1)
      end
      it "blocks create" do
        expect { 
          DeepImport.import do 
            c = Child.new 
            c.create_parent
          end
        }.to raise_error
        expect { 
          DeepImport.import do 
            c = Child.new 
            c.create_parent!
          end
        }.to raise_error
        expect(Child.count).to eq(0)
        expect(Parent.count).to eq(0)
      end

      it "redirects create to build with option" do
        DeepImport.import reset: true, on_save: :noop do 
          expect { 
            c = Child.new 
            c.create_parent
          }.to_not raise_error
          expect { 
            c = Child.new
            c.create_parent!
          }.to_not raise_error
          expect(Child.count).to eq(0)
          expect(Parent.count).to eq(0)
        end
        expect(Child.count).to eq(2)
        expect(Parent.count).to eq(2)
      end
    end
  end

  describe "Has Many" do
    it "creates normally if not importing" do
      parent = Parent.new
      parent.save! 
      parent.children.create
      parent.children.create!
      expect(Child.count).to eq(2)
      expect(Child.where.not(parent_id: nil).count).to eq(2)
    end

    describe "import" do
      it "builds" do
        DeepImport.import do 
          c = Child.new 
          c.grand_children.build
        end
        expect(Child.count).to eq(1)
        expect(GrandChild.count).to eq(1)
      end
      it "blocks create" do
        expect { 
          DeepImport.import do 
            c = Child.new 
            c.grand_children.create
          end
        }.to raise_error
        expect { 
          DeepImport.import do 
            c = Child.new 
            c.grand_children.create!
          end
        }.to raise_error
        expect(Child.count).to eq(0)
        expect(GrandChild.count).to eq(0)
      end
      it "redirects create to build with option" do
        DeepImport.import reset: true, on_save: :noop do 
          c = Child.new
          expect { 
            c.grand_children.create
          }.to_not raise_error
          expect { 
            c.grand_children.create!
          }.to_not raise_error
          expect(Child.count).to eq(0)
          expect(Parent.count).to eq(0)

        end
        expect(Child.count).to eq(1)
        expect(GrandChild.count).to eq(2)
      end
    end
  end
end
