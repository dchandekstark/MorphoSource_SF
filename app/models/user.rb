class User < ApplicationRecord
  has_one :media_cart, dependent: :destroy
  has_many :cart_items, through: :media_cart

  after_create :create_user_media_cart

  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles


  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  # Mailboxer (the notification system) needs the User object to respond to this method
  # in order to send emails
  def mailboxer_email(_object)
    email
  end

  # Create shopping cart for user when they create an account
  def create_user_media_cart
    MediaCart.create( { user_id: self.id } )
  end

  def items_in_cart
    cart_items.select{ |i| i.in_cart == true }
  end

  def item_ids_in_cart
    items_in_cart.map{ |i| i.id }
  end

  def work_ids_in_cart
    items_in_cart.map{ |i| i.work_id }
  end

  def downloaded_items
    cart_items.select{ |i| i.date_downloaded.present? }
  end

  def downloaded_item_ids
    downloaded_items.map{ |i| i.id }
  end

  def downloaded_work_ids
    downloaded_items.map{ |i| i.work_id }
  end
end
