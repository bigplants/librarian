class BooksController < ApplicationController

  before_action :set_book, only: [:show, :edit, :update, :destroy]

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
  end

  # GET /books/1
  # GET /books/1.json
  def show
    require 'amazon/ecs'
    Amazon::Ecs.configure do |options|
      options[:AWS_access_key_id] = 'AKIAIMN7UR4W3SWPA6YQ'
      options[:AWS_secret_key] = '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'
      options[:associate_tag] = 'brahman-20'
    end
    res = Amazon::Ecs.item_search(@book.title, {:response_group => 'Medium', :sort => 'salesrank'})

    # Find elements matching 'Item' in response object
    res.items.each do |item|
      # Retrieve string value using XML path
      item.get('ASIN')
      item.get('ItemAttributes/Title')

      # Return Amazon::Element instance
      item_attributes = item.get_element('ItemAttributes')
      item_attributes.get('Title')

      item_attributes.get_unescaped('Title') # unescape HTML entities
      item_attributes.get_array('Author')    # ['Author 1', 'Author 2', ...]
      item_attributes.get('Author')          # 'Author 1'

      # Return a hash object with the element names as the keys
      item.get_hash('SmallImage') # {:url => ..., :width => ..., :height => ...}

      # Return the first matching path
      item_height = item.get_element('ItemDimensions/Height')
      item_height.attributes['Units']        # 'hundredths-inches'

      # There are two ways to find elements:
      # 1) return an array of Amazon::Element
      reviews = item.get_elements('EditorialReview')
      reviews.each do |review|
        el.get('Content')
      end

      # 2) return Nokogiri::XML::NodeSet object or nil if not found
      reviews = item/'EditorialReview'
      reviews.each do |review|
        el = Amazon::Element.new(review)
        el.get('Content')
      end
    end

    p res
    @book
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html {redirect_to @book, notice: 'Book was successfully created.'}
        format.json {render :show, status: :created, location: @book}
      else
        format.html {render :new}
        format.json {render json: @book.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html {redirect_to @book, notice: 'Book was successfully updated.'}
        format.json {render :show, status: :ok, location: @book}
      else
        format.html {render :edit}
        format.json {render json: @book.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html {redirect_to books_url, notice: 'Book was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Book.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def book_params
    params.require(:book).permit(:title, :description)
  end
end
