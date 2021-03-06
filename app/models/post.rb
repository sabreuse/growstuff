class Post < ActiveRecord::Base
  extend FriendlyId
  friendly_id :author_date_subject, use: :slugged
  attr_accessible :body, :subject, :author_id, :forum_id
  belongs_to :author, :class_name => 'Member'
  belongs_to :forum
  has_many :comments, :dependent => :destroy
  # also has_many notifications, but kinda meaningless to get at them
  # from this direction, so we won't set up an association for now.

  default_scope order("created_at desc")

  validates :subject,
    :format => {
      :with => /\S/
    }

  def author_date_subject
    # slugs are created before created_at is set
    time = created_at || Time.zone.now
    "#{author.login_name} #{time.strftime("%Y%m%d")} #{subject}"
  end

  def comment_count
    self.comments.count
  end

  # return the timestamp of the most recent activity on this post
  # i.e. the time of the most recent comment, or of the post itself if
  # there are no comments.
  def recent_activity
    self.comments.present? ? self.comments.reorder('created_at DESC').first.created_at : self.created_at
  end

  # return posts sorted by recent activity
  def Post.recently_active
    Post.all.sort do |a,b|
      b.recent_activity <=> a.recent_activity
    end
  end

end
