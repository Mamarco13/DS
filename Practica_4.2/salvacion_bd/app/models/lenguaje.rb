class Lenguaje < ApplicationRecord
  has_many :palabras, dependent: :destroy

  validates :nombre, presence: true, uniqueness: true
end
