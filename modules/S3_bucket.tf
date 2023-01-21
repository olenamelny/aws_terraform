resource "aws_s3_bucket" "assignment-bucket1" {
  bucket = "assignment-bucket1"
  acl    = "private"
  tags = {
    Name        = "assignment-bucket1"
  }
}

resource "aws_s3_object" "Images" {
  bucket = aws_s3_bucket.assignment-bucket1.id
  key    = "images/"
}

resource "aws_s3_object" "Logs" {
  bucket = aws_s3_bucket.assignment-bucket1.id
  key    = "logs/"
}

# Bucker Versioning
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.assignment-bucket1.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle Policy 
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_rule" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.my_bucket_versioning]

  bucket = aws_s3_bucket.assignment-bucket1.bucket

  rule {
    id = "archive"
    status = "Enabled"

    filter {
      prefix = "images/"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }
  }
#} 

rule {
    id = "delete"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

