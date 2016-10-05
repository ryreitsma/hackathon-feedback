class User < ApplicationRecord
  has_many :requested_feedback, class_name: 'FeedbackRequest'
  has_and_belongs_to_many :invitations, class_name: 'FeedbackRequest', join_table: 'feedback_requests_users', foreign_key: :user_id
  has_many :goals, foreign_key: :owner_id
  has_many :given_feedback, class_name: 'Feedback', foreign_key: :author_id
  has_many :received_feedback, class_name: 'Feedback', foreign_key: :subject_id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :omniauthable, :omniauth_providers => [:google_oauth2]

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first_or_create

    user.name = data["name"]
    user.save!

    user
  end

  def pending_requests
    invitations.where.not(id: given_feedback.collect {|feedback| feedback.feedback_request_id})
  end
end
