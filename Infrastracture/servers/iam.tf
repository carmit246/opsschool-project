resource "aws_iam_role" "opsschool-project" {
  name = "opsschool-project"

  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      Name = "opsschool-project"
  }
}

resource "aws_iam_instance_profile" "opsschool-project" {
  name = "opsschool-project"
  role = "${aws_iam_role.opsschool-project.name}"
}

resource "aws_iam_role_policy" "opsschool-project" {
  name = "opsschool-project"
  role = "${aws_iam_role.opsschool-project.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
} 