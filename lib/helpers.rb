require 'narray'
require 'tf-idf-similarity'

include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Blogging
include Nanoc::Helpers::LinkTo

def preview?(item)
  item[:preview] && item[:preview] == true
end

def special?(item)
  item[:special] && item[:special] == true
end

def old?(item)
  attribute_to_time(item[:created_at]).to_i - Time.now.to_i <= -2 * 3600 * 24 * 365
end

def deprecated?(item)
  item[:deprecated] && item[:deprecated] == true
end

def sorted_special_articles
  sorted_articles.select { |item| special?(item) && !preview?(item) }
end

def sorted_published_articles
  sorted_articles.select { |item| !preview?(item) }
end

def abstract?(item)
  !item[:abstract].nil?
end

def abstract(item)
  item[:abstract]
end

def similar_posts(item)
  article_index ||= sorted_articles
    .map{ |article| TfIdfSimilarity::Document.new(article.compiled_content(snapshot: :raw)) }

  tfidf_model ||= TfIdfSimilarity::TfIdfModel.new article_index, library: :narray

  similarity_matrix ||= tfidf_model.similarity_matrix

  item_index = sorted_articles.find_index { |i| i.identifier == item.identifier }

  similar_posts = article_index.map do |article|
    {
      article_index: tfidf_model.document_index(article),
      similarity: similarity_matrix[item_index, tfidf_model.document_index(article)]
    }
  end

  similar_posts.sort_by! { |post| -post[:similarity] }

  similar_posts
end
