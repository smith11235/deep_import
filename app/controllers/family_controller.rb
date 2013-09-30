class FamilyController < ApplicationController
	
	# for easily viewing markdown files in development
	def markdown
		@file = params[:file]
	end

  def index
  end
end
