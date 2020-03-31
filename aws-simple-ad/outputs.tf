output "directory_id" {
	value = aws_directory_service_directory.bar.id
}

output "access_url" {
	value = aws_directory_service_directory.bar.access_url
}

output "directory_passort" {
	value = random_string.pwd.result
}

output "dns_ip_addresses" {
	value = aws_directory_service_directory.bar.dns_ip_addresses
}
