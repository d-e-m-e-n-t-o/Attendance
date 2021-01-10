# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# coding: utf-8

User.create!(name: "上長A",
             email: "sample-1@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "1",
             uid: SecureRandom.urlsafe_base64,
             superior: true)
             
User.create!(name: "上長B",
             email: "sample-2@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "2",
             uid: SecureRandom.urlsafe_base64,
             superior: true)
             
User.create!(name: "上長C",
             email: "sample-3@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "3",
             uid: SecureRandom.urlsafe_base64,
             superior: true)
             
User.create!(name: "管理者A",
             email: "sample-4@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "4",
             uid: SecureRandom.urlsafe_base64,
             admin: true)

User.create!(name: "管理者B",
             email: "sample-5@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "5",
             uid: SecureRandom.urlsafe_base64,
             admin: true)
             
User.create!(name: "管理者C",
             email: "sample-6@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "6",
             uid: SecureRandom.urlsafe_base64,
             admin: true)


(6..19).each do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  employee_number = "#{n+1}"
  uid = SecureRandom.urlsafe_base64
  User.create!(name: name,
               email: email,
               employee_number: employee_number,
               uid: uid,
               password: password,
               password_confirmation: password)
end
               
3.times do |n|
  number = n+1
  name = "拠点#{n+1}"
  Base.create!(number: number,
               name: name)
end