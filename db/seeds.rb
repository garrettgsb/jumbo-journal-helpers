# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create name: 'Garrett', password: 'asdf'

Journal.create title: "Neat birds I saw", user: User.first

Entry.create title: "Bald eagle, seemed lost", body: "This eagle spent like an hour circling the area near Canada Place. It went toward Chinatown for a bit, and then back to Canada Place. I think eventually, it just parked on a roof somewhere, and is probably asking for directions.", user: User.first, journal: Journal.first
Entry.create title: "Six pigeons fighting over french fries", body: "Pigeons fighting over food is not an uncommon sight. But what was interesting about this instance is that they seemed to have formed teams.", user: User.first, journal: Journal.first
