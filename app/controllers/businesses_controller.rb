class BusinessesController < ApplicationController
  before_action :set_business, only: [:show, :destroy]
  before_action :set_my_business, only: [:edit, :update]
  skip_before_action :user_needs_business

  # GET /businesses
  # GET /businesses.json
  # def index
  #   @businesses = Business.all
  # end

  # GET /businesses/1
  # GET /businesses/1.json
  def show
    unless (click = Click.where(clicker: current_user.business, clicked: @business).first).nil?
      click.count += 1
      click.save
    end
    @note = Note.new
    redirect_to my_business_path if current_user.business == @business
  end

  # GET /businesses/new
  def new
    @business = Business.new
  end

  # GET /businesses/1/edit
  def edit
  end


  # POST /businesses
  # POST /businesses.json
  def create
    create_hash = create_params
    create_hash["industries"] = create_hash["industries"].split(', ').map{ |e| e.strip.capitalize }
    create_hash["employees"] = Business.employees.invert[create_hash["employees"]]
    # raise
    @business = Business.new(create_hash)
    @business.users << current_user
    @business.add_domain
    # raise
    respond_to do |format|
      if @business.save
        update_business(@business, update_params)
        @business.create_suggestions
        format.html { redirect_to suggestions_path, notice: 'Business was successfully created.' }
        format.json { render :show, status: :created, location: @business }
      else
        format.html { render :new }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /businesses/1
  # PATCH/PUT /businesses/1.json
  def update
    create_hash = create_params
    create_hash["industries"] = create_hash["industries"].split(', ').map{ |e| e.strip.capitalize }
    # raise
    respond_to do |format|
      if @business.update(create_hash) && update_business(@business, update_params)
        format.html { redirect_to @business, notice: 'Business was successfully updated.' }
        format.json { render :show, status: :ok, location: @business }
      else
        format.html { render :edit }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /businesses/1
  # DELETE /businesses/1.json
  def destroy
    @business.destroy
    respond_to do |format|
      format.html { redirect_to businesses_url, notice: 'Business was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def my_business
    @business = current_user.business
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_business
      @business = Business.find(params[:id])
    end

    def set_my_business
      @business = current_user.business
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def edit_business_params
      params.require(:business).permit(:name, :industries, :employees, :other_partners, :other_competitors, :desired_partnership_types, :offered_partnership_types, :url, :description, :title, :body, :photo)
    end

    def business_params
      params.permit(:name, :tagline, :url, :photo, :photo_cache, :industries, :employees, :acq_partners, :des_partners, :other_partners, :other_competitors, :desired_partnership_types, :offered_partnership_types, :customer_interests)
    end

    def update_params
      params.permit(:other_competitors, :acq_partners, :des_partners, :customer_interests)
    end

    def create_params
      params.permit(:name, :tagline, :url, :photo, :industries, :youtube_url, :employees, :file, desired_partnership_types: [], offered_partnership_types: [])
    end

    def update_business(current_business, base_hash)
      # current_business.other_partners = []
      # current_business.other_competitors = []

      # acquired partnerships
      acquired_partnerships = base_hash["acq_partners"].split(', ')

      acquired_partnerships.each do |acq|
        if acq_bus = Business.where("lower(name) LIKE ?", "#{acq}".downcase).first
          current_business.partnerships.acquired.where(partner: acq_bus).first_or_create
        else
          current_business.other_partners << acq + " (acq)"
          current_business.save!
        end
      end

      # desired partnerships
      desired_partnerships = base_hash["des_partners"].split(', ')

      desired_partnerships.each do |des|
        if des_bus = Business.where("lower(name) LIKE ?", "#{des}".downcase).first
          current_business.partnerships.desired.where(partner: des_bus).first_or_create
        else
          current_business.other_partners << des + " (des)"
          current_business.save!
        end
      end

      # competitors
      competitors = base_hash["other_competitors"].split(', ')

      competitors.each do |competitor|
        if comp = Business.where("lower(name) LIKE ?", "#{competitor}".downcase).first
          current_business.competitions.where(competitor: comp).first_or_create
        else
          current_business.other_competitors << competitor
          current_business.save!
        end
      end

      # interests
      interests = base_hash["customer_interests"].split(', ')

      interests.each do |interest|
        current_business.business_customer_interests.create!(
          customer_interest: CustomerInterest.where(name: interest).first_or_create
        )
      end

      # raise
      # save updates
      current_business.save!
    end
end
