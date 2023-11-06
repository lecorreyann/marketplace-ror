class Category < ApplicationRecord
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Category", optional: true

  validate :category_cannot_be_its_own_parent

  private

  def category_cannot_be_its_own_parent
    if parent == self
      errors.add(:parent, "Category cannot be its own parent")
    end
  end
end
