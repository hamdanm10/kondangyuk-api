admin = User.find_or_initialize_by(email: "admin@kondangyuk.test")
unless admin.persisted?
  admin.password = "AdminKondangyuk@2024"
  admin.role = "admin"
  admin.save!
  puts "Created admin: #{admin.email}"
end

super_admin = User.find_or_initialize_by(email: "superadmin@kondangyuk.test")
unless super_admin.persisted?
  super_admin.password = "SuperAdminKondangyuk@2024"
  super_admin.role = "super_admin"
  super_admin.save!
  puts "Created super_admin: #{super_admin.email}"
end
