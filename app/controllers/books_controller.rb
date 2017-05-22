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
      options[:AWS_access_key_id] = ENV['AWS_ACCESS_KEY_ID']
      options[:AWS_secret_key] = ENV['AWS_SECRET_ACCESS_KEY']
      options[:associate_tag] = ENV['ASSOCIATE_TAG']
    end
    res = Amazon::Ecs.item_search(@book.title, {
        :search_index => 'Books',
        :item_page => 1,
        :response_group => 'Medium,ItemAttributes,Images',
        :country => 'jp'
    })

    # Find elements matching 'Item' in response object
    res.items.each do |item|
      puts item_attributes = item.get_element('ItemAttributes')
      p item_attributes.get('Title')
      p item_attributes.get('Author')
      p item_attributes.get('ISBN')

      # Return a hash object with the element names as the keys
      p item.get_hash('SmallImage') # {:url => ..., :width => ..., :height => ...}

      break
    end
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
