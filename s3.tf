# ============================================================
# S3 Bucket (파일 저장소)
# ============================================================
resource "aws_s3_bucket" "everybuddy_files" {
  bucket = "everybuddy-files-prod-20250103"
  
  tags = {
    Name        = "EveryBuddy Files"
    Environment = "prod"
    Project     = "everybuddy"
  }
}

# ============================================================
# S3 버킷 버저닝
# ============================================================
resource "aws_s3_bucket_versioning" "everybuddy_files" {
  bucket = aws_s3_bucket.everybuddy_files.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# ============================================================
# S3 CORS 설정
# ============================================================
resource "aws_s3_bucket_cors_configuration" "everybuddy_files" {
  bucket = aws_s3_bucket.everybuddy_files.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# ============================================================
# S3 퍼블릭 액세스 차단
# ============================================================
resource "aws_s3_bucket_public_access_block" "everybuddy_files" {
  bucket = aws_s3_bucket.everybuddy_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
