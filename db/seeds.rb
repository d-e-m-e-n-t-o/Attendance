# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# coding: utf-8

User.create!(name: "上長A",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "1",
             superior: true)
             
User.create!(name: "上長B",
             email: "sample-1@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "2",
             superior: true)
             
User.create!(name: "上長C",
             email: "sample-2@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "3",
             superior: true)
             
User.create!(name: "管理者A",
             email: "sample-3@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "4",
             admin: true)

User.create!(name: "管理者B",
             email: "sample-4@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)
             
User.create!(name: "管理者C",
             email: "sample-5@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "5",
             admin: true)


60.times do |n|
  name  = Faker::Name.name
  email = "sample#{n+1}@email.com"
  password = "password"
  employee_number = "#{n+1}"
  User.create!(name: name,
               email: email,
               employee_number: employee_number,
               password: password,
               password_confirmation: password)
end