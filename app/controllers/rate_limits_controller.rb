class RateLimitsController < ApplicationController
  before_action :set_rate_limit, only: [:show, :edit, :update, :destroy]

  # GET /rate_limits
  # GET /rate_limits.json
  def index
    @rate_limits = RateLimit.all
  end

  # GET /rate_limits/1
  # GET /rate_limits/1.json
  def show
  end

  # GET /rate_limits/new
  def new
    @rate_limit = RateLimit.new
  end

  # GET /rate_limits/1/edit
  def edit
  end

  # POST /rate_limits
  # POST /rate_limits.json
  def create
    @rate_limit = RateLimit.new(rate_limit_params)

    respond_to do |format|
      if @rate_limit.save
        format.html { redirect_to @rate_limit, notice: 'Rate limit was successfully created.' }
        format.json { render :show, status: :created, location: @rate_limit }
      else
        format.html { render :new }
        format.json { render json: @rate_limit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rate_limits/1
  # PATCH/PUT /rate_limits/1.json
  def update
    respond_to do |format|
      if @rate_limit.update(rate_limit_params)
        format.html { redirect_to @rate_limit, notice: 'Rate limit was successfully updated.' }
        format.json { render :show, status: :ok, location: @rate_limit }
      else
        format.html { render :edit }
        format.json { render json: @rate_limit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rate_limits/1
  # DELETE /rate_limits/1.json
  def destroy
    @rate_limit.destroy
    respond_to do |format|
      format.html { redirect_to rate_limits_url, notice: 'Rate limit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rate_limit
      @rate_limit = RateLimit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rate_limit_params
      params[:rate_limit]
    end
end
