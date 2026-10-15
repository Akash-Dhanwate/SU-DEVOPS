output "app_server_public_ip" {
  value = aws_instance.app.public_ip
}

output "app_url" {
  value = "http://${aws_instance.app.public_ip}"
}

output "backup_bucket" {
  value = aws_s3_bucket.backup.bucket
}

output "vpc_id" {
  value = aws_vpc.main.id
}
