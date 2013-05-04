class DummyModel < ActiveRecord::Base
  belongs_to :dummy_model
	has_many :dummy_models
  attr_accessible :name
end
