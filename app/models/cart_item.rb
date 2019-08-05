class CartItem < ApplicationRecord
  belongs_to :media_cart
  paginates_per 10

  before_create :set_approver

  def requester
    self.media_cart.user
  end

  def requester_email
    requester.email
  end

  def requester_affiliation
    requester.affiliation
  end

  def unrestricted?
    !self.restricted?
  end

  def request_status
    if self.date_canceled.present?
      "Canceled"
    elsif self.date_denied.present?
      "Denied"
    elsif self.expired?
      "Expired"
    elsif self.date_approved.present?
      "Approved"
    elsif self.date_requested.present?
      "Requested"
    elsif self.restricted?
      "Not Requested"
    elsif self.downloadable?
      "Downloadable"
    end
  end

  def downloadable?
    self.unrestricted? || self.request_status == 'Approved'
  end

  def approving_user
    User.find_by email: self.approver
  end

  def work
    Media.find(self.work_id)
  end

  def expired?
    return false unless self.date_expired
    self.date_expired < Time.now
  end

  # for now, approver = depositor
   def set_approver
    self.approver = work.depositor
  end
end
