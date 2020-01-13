class Scraping

  # 表示されている20件分の映画の個別ページのリンクURLを取得して、そのリンクをクラスメソッドget_productを渡す処理をする
  def self.movie_urls
    # linksという配列の空枠を作る
    links = []

    # Mechanizeクラスのインスタンスを生成する
    agent = Mechanize.new

    # パスの部分を変数で定義
    next_url = ""

    while true

      # 映画の全体ページのURLを取得
      current_page = agent.get("http://review-movie.herokuapp.com" + next_url)

      # 全体ページから映画1ページ分（20件）の個別URLのタグを取得
      elements = current_page.search('.entry-title a')

      # 個別URLのタグからhref要素を取り出し、links配列に格納する
      elements.each do |emt|
        links << emt.get_attribute('href')
      end

      # 「次へ」を表すタグを取得
      next_link = current_page.at('.pagination .next a')

      # next_urlがなかったらwhile文を抜ける
      break unless next_link

      # そのタグからhref属性の値を取得
      next_url = next_link.get_attribute('href')
    end

    # get_productを実行する際にリンクを引数として渡す
    links.each do |link|
      get_product('http://review-movie.herokuapp.com/' + link)
    end
  end

  # 引数として渡された個別ページのリンクURLを使って「作品名」と「作品画像のURL」をスクレイピングし、それらをproductsテーブルに保存する
  def self.get_product(link)
    # Mechanizeクラスのインスタンスを生成する
    agent = Mechanize.new

    # 映画の個別ページのURLを取得
    page = agent.get(link)

    # inner_textメソッドを利用し映画のタイトルを取得
    title = page.at('.entry-title').inner_text if page.at('.entry-title')

    # image_urlがあるsrc要素のみを取り出す
    # [:src]は「get_attribute('src')」と同じ
    image_url = page.at('.entry-content img')[:src] if page.at('.entry-content img')

    # 「監督名」、「あらすじ」、「公開日」を追加
    director = page.at('.director span').inner_text if page.at('.director span')
    detail = page.at('.entry-content p').inner_text if page.at('.entry-content p')
    open_date = page.at('.date span').inner_text if page.at('.date span')

    # newメソッド、saveメソッドを使い、 スクレイピングした「映画タイトル」と「作品画像のURL」をproductsテーブルに保存
    # product = Product.new(title: title, image_url: image_url)
    # 同じ映画の情報がデータベースにすでに保存されていた場合、空のインスタンスは作らずに、既に保存されているレコードを更新するように修正
    product = Product.where(title: title).first_or_initialize
    product.image_url = image_url
    product.director = director
    product.detail = detail
    product.open_date = open_date
    product.save
  end
end