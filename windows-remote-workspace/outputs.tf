output "directory_name" {
  value = aws_directory_service_directory.main.name
  description = "Name of the directory to be used with WorkSpaces"
}

output "directory_id" {
  value = aws_directory_service_directory.main.id
  description = "ID of directory to be used with WorkSpaces"
}
