require 'spec_helper'

describe 'DeepImport::ModelLogic - General API' do
	it "should have teardown logic"

	describe Child do
    before :each do 
      DeepImport.initialize!(reset: true)
    end

    describe "DeepImport Module Includes" do
      it "is loaded" do
        puts "DeepImport.status =  #{DeepImport.status}".red
        expect(DeepImport.ready_for_import?).to be true
      end

      it "includes ModelLogic" do
        # TODO: change to Importable
        expect(Child.included_modules.include?(DeepImport::ModelLogic)).to be true
        expect(Child.included_modules.include?(DeepImport::ModelLogic::Saveable)).to be true
      end
      it "includes BelongsTo" do
        expect(Child.included_modules.include?(DeepImport::ModelLogic::BelongsTo)).to be true
      end
      it "includes HasMany" do
        pending
        # TODO: how to test the proxy association inclusion
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
  			it "deep imports initialized instance" do
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
      it "creates normally if not importing"
      describe "import" do
        it "builds"
        it "blocks create"
        it "allows create with option"
      end
    end

    describe "Has Many" do
      it "creates normally if not importing"
      describe "import" do
        it "builds"
        it "blocks create"
        it "allows create with option"
      end
    end
	end
end
