
admin = User.create(
  username: "admin",
  email: "admin@brgen.no",
  name: "Administrator",
  gender: "male",
  # password: Settings.admin.password
  password: "Ahp5mae1"
)
admin.forem_admin = true
admin.save!

