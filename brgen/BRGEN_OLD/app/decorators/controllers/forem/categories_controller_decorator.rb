Forem::CategoriesController.class_eval do
  before_action :find_category

  def show
    register_view if @category

    @topics = @category.topics
  end

private
  def find_category
    @category = Forem::Category.find(params[:id])
  end

  def register_view
    @category.register_view_by(forem_user)
  end

protected
  def category_params
    params.require(:category).permit(:parent_id, :value, :expires_in, :newsworthy)
  end
end

