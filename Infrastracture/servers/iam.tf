/* resource "aws_iam_role" "lesson3hw_role" {
  name = "lesson3hw_role"

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
      Name = "lesson3hw"
  }
}

resource "aws_iam_instance_profile" "lesson3hw_profile" {
  name = "lesson3hw_profile"
  role = "${aws_iam_role.lesson3hw_role.name}"
}

resource "aws_iam_role_policy" "lesson3hw_policy" {
  name = "lesson3hw_policy"
  role = "${aws_iam_role.lesson3hw_role.id}"

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
} */