# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Change these values, especially everything after the two User instances.

admin_u = User.find_or_create_by(email: 'admin@me.com') do |u|
  u.password='admin123'
  u.admin=true
end

u2 = User.find_or_create_by(email: 'just_u@me.com') do |u|
  u.password='userme123'
  u.admin=false
end
