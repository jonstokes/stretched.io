class ScrapesController < ApplicationController

  # POST /scrapes
  def build
    @scrape = Scrape.new(scrape_params)

    respond_to do |format|
      format.js
    end
  end

  private
    def scrape_params
      params[:scrape]
    end
end
