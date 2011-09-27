# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# require 'rubygems'
# require 'random_data'
# require 'forgery'

puts 'CREATING users'

# = form_for @course, :html => { :multipart => true } do |f|
#   / = f.error_messages
#   %p
#     = f.label :title
#     %br
#     = f.text_field :title
#   %p
#     = f.label :description
#     %br
#     = f.text_area :description
#   %p
#     = f.label :price
#     %br
#     = f.text_field :price
#   %p
#     = f.label :seats
#     %br
#     = f.text_field :seats
#   %p
#     = f.label :date
#     %br
#     = f.date_select :date
#   %p
#     = f.label :time
#     %br
#     = f.time_select :time
#   %p
#     = f.label "Address"
#     %br
#     = f.text_field :place
#   
#   %p
#     = f.label "Minimum students needed for the class to happen"
#     %br
#     = f.text_field :minimum
#   %p
#     = f.label :photo
#     %br
#     = f.file_field :photo
#   %p

 # @course = Course.new(params[:course])
 #  @user = current_user
 #  if @course.save
 #    @crole = Crole.find_by_course_id_and_user_id(@course.id, current_user.id) 
 #    if @crole.nil?
 #      @crole = @course.croles.create!(:attending => true, :role => 'teacher')
 #      @user.croles << @crole
 #      @user.courses << @course
 #      @user.save
 #    end
 #    redirect_to @course, :notice => "Successfully created course."
 #  else
 #    render :action => 'new'
 #  end

# user1 = User.create! :name => 'John Doe', :email => 'johndoe@test.com', :password => 'testing', :password_confirmation => 'testing', :location => "Austin"
# puts 'New user created: ' << user1.name
# user2 = User.create! :name => 'Jane Doe', :email => 'janedoe@test.com', :password => 'testing', :password_confirmation => 'testing', :location => "Austin"
# puts 'New user created: ' << user2.name



(1..100).each do |count|
  name = "#{Random.firstname} #{Random.initial} #{Random.lastname}"
  email = "austin_#{count}@test.com"
  password = "testing"
  location = "Austin"
  user = User.create! :name => name, :email => email, :password => password, :password_confirmation => password, :location => location
  user.save
  
  random_text = Random.paragraphs
  title = random_text.split(/\s+/)[0..3].join(' ')
  description = random_text
  price = Forgery(:monetary).money :min => 5, :max => 20
  seats = rand(20)
  seats = 10 unless seats != 0
  date = Random.date(0..21)
  time = Time.now.gmtime
  address = Random.address_line_1
  minimum = rand(5)
  minimum = 1 unless minimum < seats && minimum != 0
  
  course = Course.create! :title => title, :description => description, :price => price, :seats => seats, :date => date, :time => time, :place => address, :minimum => minimum
  if course.save
    crole = Crole.find_by_course_id_and_user_id(course.id, user.id) 
    if crole.nil?
       crole = course.croles.create!(:attending => true, :role => 'teacher')
       user.croles << crole
       user.courses << course
       user.save
     end
     p "created course #{course.title}, #{course.price}, by #{user.name}"
  end
  
  #create two suggestions per user
  random_text = Random.paragraphs(1)
  sugg_name = random_text.split(/\s+/)[0..2].join(' ')
  sugg_desc = random_text
  sugg_requested_by = user.id
  csugg = Csuggestion.create! :name => sugg_name, :description => sugg_desc, :requested_by => sugg_requested_by
  user.vote_for(csugg)
  #create courses randomly
end


# user1.save
# user2.save

puts 'CREATING members'
member1 = Member.create! :name => 'Saran Vigraham', :email => 'saranyan.vigraham@ac4d.com', :password => 'testing',:password_confirmation => 'testing', :organizaiton => 'ac4d'
member1.save
puts "New member created"
member2 = Member.create! :name => 'Vigraham Saran', :email => 'svigraham@gmail.com', :password => 'testing',:password_confirmation => 'testing', :organizaiton => 'ac4d'
member2.save
puts "New member created"

puts 'SETTING UP ENTERPRISE'
ent1 = Enterprise.create! :area => 'Austin, Texas', :name => 'Austin Center for Design', :domain => 'ac4d'
ent2 = Enterprise.create! :area => 'Austin, Texas', :name => 'Google', :domain => 'gmail'

puts 'SETTING UP  SUBDOMAINS/COMPANIES'
subdomain1 = Subdomain.create! :name => 'ac4d'
puts 'Created subdomain: ' << subdomain1.name
subdomain2 = Subdomain.create! :name => 'gmail'
puts 'Created subdomain: ' << subdomain2.name
ent1.subdomain = subdomain1
ent1.save
ent2.subdomain = subdomain2
ent2.save