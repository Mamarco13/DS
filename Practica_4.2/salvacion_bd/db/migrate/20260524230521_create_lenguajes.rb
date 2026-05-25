class CreateLenguajes < ActiveRecord::Migration[8.1]
  def change
    create_table :lenguajes do |t|
      t.string :nombre

      t.timestamps
    end
  end
end
