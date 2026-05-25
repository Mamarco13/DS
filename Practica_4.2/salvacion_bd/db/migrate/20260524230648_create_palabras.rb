class CreatePalabras < ActiveRecord::Migration[8.1]
  def change
    create_table :palabras do |t|
      t.string :texto
      t.string :tipo
      t.float :duracion
      t.jsonb :espectrograma
      t.references :lenguaje, null: false, foreign_key: true

      t.timestamps
    end
  end
end
