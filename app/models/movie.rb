class Movie < ApplicationRecord
  validates :title, :overview, :poster_url, :rating, presence: true
  validates :overview, presence: true

  has_many :bookmarks
end
