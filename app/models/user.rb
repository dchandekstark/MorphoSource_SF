class User < ApplicationRecord
  has_one :media_cart, dependent: :destroy
  has_many :cart_items, through: :media_cart

  paginates_per 10

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

  def cart_id
    media_cart.id
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

  # restricted items user has added to cart
  def restricted_items_in_cart
    items_in_cart.select{ |item| item.restricted? }
  end

  def restricted_items_in_cart_ids
    restricted_items_in_cart.map{ |item| item.id }
  end

  def downloadable_items
    cart_items.select{ |item| item.downloadable? }
  end

  def downloadable_ids
    downloadable_items.map{ |item| item.id }
  end

  def downloadable_item_work_ids
    downloadable_items.map{ |item| item.work_id }
  end

  def downloadable_items_in_cart
    items_in_cart.select{ |item| item.downloadable? }
  end

  def downloadable_ids_in_cart
    downloadable_items_in_cart.map{ |item| item.id }
  end

  # all a user's current and past requests (items where user is requestor)
  def my_requests
    cart_items.select{ |item| (item.date_requested.present? || item.date_cleared.present?) }
  end

  def my_requests_ids
    my_requests.map{ |item| item.id }
  end

  def my_requests_work_ids
    my_requests.map{ |item| item.work_id }
  end

  def my_active_requests
    active_statuses = ["Approved","Requested","Cleared"]
    my_requests.select{ |item| active_statuses.include?(item.request_status) }
  end

  def my_active_requests_work_ids
    my_active_requests.map{ |item| item.work_id }
  end

  # items requested from user (items where user is data manager)
  def requested_items
    CartItem.where(approver: self.email).where(restricted: true).where.not(date_requested: nil).or(CartItem.where(approver: self.email).where(restricted: true).where.not(date_cleared: nil))
  end

  def newly_requested_items
    requested_items.select{|item| item.request_status == "Requested"}
  end

  def previously_requested_items
    requested_items - newly_requested_items
  end

  def requested_item_ids
    requested_items.map{|item| item.id}
  end

  def previously_requested_item_ids
    previously_requested_items.map{|item| item.id}
  end

  def newly_requested_item_ids
    newly_requested_items.map{|item| item.id}
  end

  def requested_items_work_ids
    requested_items.map{ |item| item.work_id }
  end

  def previously_requested_items_work_ids
    previously_requested_items.map{ |item| item.work_id }
  end

  def newly_requested_items_work_ids
    newly_requested_items.map{ |item| item.work_id }
  end

  def newly_requested_items_user_ids
    newly_requested_items.map{ |item| item.media_cart.user_id }
  end

  def previously_requested_items_user_ids
    previously_requested_items.map{ |item| item.media_cart.user_id }
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
