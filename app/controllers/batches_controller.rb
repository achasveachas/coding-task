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

  def show
    @batch = Batch.find_by(id: params[:id])
    send_data @batch.output, type: 'text/text', filename: "output.txt", disposition: 'attachment'
  end
end
