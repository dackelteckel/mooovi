class RankingController < ApplicationController
  layout 'review_site'

  before_action :ranking

  def ranking
    # @ranking = Product.limit(5)
    # レビュー数の多いproductのid上位5つが、多い順に並んだ配列を用意します
    product_ids = Review.group(:product_id).order('count_product_id DESC').limit(5).count(:product_id).keys
    # mapメソッドを利用し、配列の中身をProductクラスのインスタンスに変換
    # ただのid番号だったものをproductsテーブルのレコードのインスタンスに変換
    @ranking = product_ids.map { |id| Product.find(id) }
  end
end
