data "aws_route53_zone" "cobli_co" {
  name         = "cobli.co."
  private_zone = true
}

resource "aws_route53_record" "deepface_dev_endpoint" {
  zone_id = data.aws_route53_zone.cobli_co.zone_id
  name    = "deepface.dev.${data.aws_route53_zone.cobli_co.name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["a1b490ac2f3504b3f8fa8bb4387849f0-194051408.us-east-1.elb.amazonaws.com"]
}
