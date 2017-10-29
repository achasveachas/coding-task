class BatchesController < ApplicationController
  def index
    @batches = Batch.all
  end

  def create
  end
end
