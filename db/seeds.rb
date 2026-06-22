admin = User.find_or_initialize_by(email: "admin@kondangyuk.test")
unless admin.persisted?
  admin.password = "AdminKondangyuk@2026"
  admin.role = "admin"
  admin.save!
  puts "Created admin: #{admin.email}"
end

super_admin = User.find_or_initialize_by(email: "superadmin@kondangyuk.test")
unless super_admin.persisted?
  super_admin.password = "SuperAdminKondangyuk@2026"
  super_admin.role = "super_admin"
  super_admin.save!
  puts "Created super_admin: #{super_admin.email}"
end

designer = User.find_or_initialize_by(email: "designer@kondangyuk.test")
unless designer.persisted?
  designer.password = "DesignerKondangyuk@2026"
  designer.role = "designer"
  designer.save!
  puts "Created designer: #{designer.email}"
end
