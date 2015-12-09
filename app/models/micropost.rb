class Micropost < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true, length: { in: 4..140 }
  validate  :picture_size
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader

  private

  def picture_size
    errors.add(:picture, 'Should be less than 5MB') if picture.size > 5.megabytes
  end
end
