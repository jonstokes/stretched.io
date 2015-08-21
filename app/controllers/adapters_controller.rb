class AdaptersController < ApplicationController
  before_action :set_adapter, only: [:show, :edit, :update, :destroy]

  # GET /adapters
  # GET /adapters.json
  def index
    @adapters = Adapter.all
  end

  # GET /adapters/1
  # GET /adapters/1.json
  def show
  end

  # GET /adapters/new
  def new
    @adapter = Adapter.new
  end

  # GET /adapters/1/edit
  def edit
  end

  # POST /adapters
  # POST /adapters.json
  def create
    @adapter = Adapter.new(adapter_params)

    respond_to do |format|
      if @adapter.save
        format.html { redirect_to @adapter, notice: 'Adapter was successfully created.' }
        format.json { render :show, status: :created, location: @adapter }
      else
        format.html { render :new }
        format.json { render json: @adapter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /adapters/1
  # PATCH/PUT /adapters/1.json
  def update
    respond_to do |format|
      if @adapter.update(adapter_params)
        format.html { redirect_to @adapter, notice: 'Adapter was successfully updated.' }
        format.json { render :show, status: :ok, location: @adapter }
      else
        format.html { render :edit }
        format.json { render json: @adapter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /adapters/1
  # DELETE /adapters/1.json
  def destroy
    @adapter.destroy
    respond_to do |format|
      format.html { redirect_to adapters_url, notice: 'Adapter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_adapter
      @adapter = Adapter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def adapter_params
      params[:adapter]
    end
end
