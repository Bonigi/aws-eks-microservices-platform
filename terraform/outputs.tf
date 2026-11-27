output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = var.region
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "app_irsa_role_arn" {
  value = module.app_irsa.iam_role_arn
}

output "app_bucket_name" {
  value = aws_s3_bucket.app.bucket
}
