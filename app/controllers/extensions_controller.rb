class ExtensionsController < ApplicationController
  before_action :set_extension, only: [:show, :edit, :update, :destroy]

  # GET /extensions
  # GET /extensions.json
  def index
    @extensions = Extension.all
  end

  # GET /extensions/1
  # GET /extensions/1.json
  def show
  end

  # GET /extensions/new
  def new
    @extension = Extension.new
  end

  # GET /extensions/1/edit
  def edit
  end

  # POST /extensions
  # POST /extensions.json
  def create
    @extension = Extension.new(extension_params)

    respond_to do |format|
      if @extension.save
        format.html { redirect_to @extension, notice: 'Extension was successfully created.' }
        format.json { render :show, status: :created, location: @extension }
      else
        format.html { render :new }
        format.json { render json: @extension.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extensions/1
  # PATCH/PUT /extensions/1.json
  def update
    respond_to do |format|
      if @extension.update(extension_params)
        format.html { redirect_to @extension, notice: 'Extension was successfully updated.' }
        format.json { render :show, status: :ok, location: @extension }
      else
        format.html { render :edit }
        format.json { render json: @extension.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /extensions/1
  # DELETE /extensions/1.json
  def destroy
    @extension.destroy
    respond_to do |format|
      format.html { redirect_to extensions_url, notice: 'Extension was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extension
      @extension = Extension.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extension_params
      params[:extension]
    end
end
