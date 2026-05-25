class Palabra < ApplicationRecord
  belongs_to :lenguaje

  TIPOS_VALIDOS = %w[verbo sustantivo adjetivo pronombre otro].freeze

  validates :texto, presence: true
  validates :tipo, inclusion: { in: TIPOS_VALIDOS }
  validates :espectrograma, presence: true
  validates :duracion, numericality: { greater_than: 0 }, allow_nil: true
end
