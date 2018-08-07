require 'singleton'
require 'matrix'
require 'tf-idf-similarity'

module SimilarPostsArticleIndex
  def self.data(value = nil)
    @@index ||= value
  end
end

module SimilarPostsModel
  def self.data(value = nil)
    @@mode ||= value
  end
end

module SimilarPostsMatrix
  def self.data(value = nil)
    @@matrix ||= value
  end
end
