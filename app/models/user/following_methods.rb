module User::FollowingMethods
  extend ActiveSupport::Concern
  DEFAULT_EXPIRES = 36.hours

  # self's relationship to user as defined by followings
  def relationship(user)
    Following.where(:follower_id => self, :followed_id => user).first.try(:relationship)||"none"
  end

  # people that attended a class that the current user follows
  def classmates
    Following.where(:follower_id => self, :relationship => 'classmate').includes(:followed).map(&:followed)
  end

  def teachers
    Following.where(:follower_id => self, :relationship => 'teacher').includes(:followed).map(&:followed)
  end

  def students
    Following.where(:follower_id => self, :relationship => 'student').includes(:followed).map(&:followed)
  end

  def follow!(followed, relationship = nil)
    return false if self == followed
    relationship ||= "friend"
    Following.create(:follower => self, :followed => followed, :relationship => relationship)
  end

  # users that follow the self
  def followers
    Following.where(:followed_id => self).includes(:follower).map(&:follower)
  end

  # users that the self follows
  def followed
    Following.where(:follower_id => self).includes(:followed).map(&:followed)
  end
  alias :following :followed

  # is self following the 'followed'
  def following?(followed)
    followed_id = followed.is_a?(User) ? followed.id : followed
    fetch_followed_ids.include?(followed_id)
  end
  alias :follows? :following?

  # ids of people that follow self
  def follower_ids
    followers.map(&:id)
  end


  def fetch_follower_ids
    cache(:expires_in => DEFAULT_EXPIRES).follower_ids
  end

  # ids of people that self has followed
  def followed_ids
    followed.map(&:id)
  end

  def fetch_followed_ids
    cache(:expires_in => DEFAULT_EXPIRES).followed_ids
  end

  def fill_as_teacher_for(course)
    course.students.each do |student|
      self.follow!(student, "student")
    end
  end
  
  def fill_as_student_for(course)
    self.follow!(course.teacher, "teacher")
    course.students.each do |student|
      self.follow!(student, "classmate")
    end
  end

  def fill_for_class(course)
    if taught?(course)
      fill_as_teacher_for(course)
    else
      fill_as_student_for(course)
    end
    # Email we added some friends to your learning circle!!
  end

  private

  def back_fill_following!
    courses_attended.each do |course|
      fill_as_student_for(course)
    end
    courses_taught.each   do |course|
      fill_as_teacher_for(course)
    end
  end

end