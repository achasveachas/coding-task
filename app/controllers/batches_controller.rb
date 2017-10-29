class BatchesController < ApplicationController
  def index
    @batches = Batch.all
    @batch = Batch.new
  end

  def create
    @batch = Batch.create(input: params[:batch][:input].read)

    @batch.parse_input

    send_data @batch.output, filename: "output.txt"
  end
end
