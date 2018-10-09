class NotesController < ApplicationController
  def create
    @business = Business.find(params[:business_id])
    @note = Note.new(owner: current_user.business, noted: @business, content: notes_params[:content], author: current_user)
    # raise
    respond_to do |format|
      if @note.save
        # raise
        format.html { redirect_to business_path(@business), notice: 'Note was successfully created.' }
      else
        format.html { redirect_to business_path(@business), alert: 'There was an error creating the note.' }
      end
    end
  end

  def notes_params
    params.require(:note).permit(:content)
  end
end
