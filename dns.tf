
# INTERNAL DNS SERVER
resource "aws_route53_zone" "private" {
  name = var.domain_name
  
  vpc {
    vpc_id = aws_vpc.main.id
  }
}

# EXTERNAL DNS SERVER
resource "aws_route53_zone" "public" {
  name = var.public_domain_name
}

resource "aws_route53_record" "httpdpub" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "machine-httpd.${var.public_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.httpd.public_ip]
}

resource "aws_route53_record" "httpd" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "httpd"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.httpd.private_ip]
}

resource "aws_route53_record" "nexusHttpProxy" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "nexus.${var.public_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.httpd.public_ip]
}

resource "aws_route53_record" "nexuspub" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "machine-nexus.${var.public_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.nexus.public_ip]
}

resource "aws_route53_record" "nexus" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "nexus"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.nexus.private_ip]
}

resource "aws_route53_record" "jenkinsHttpProxy" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "jenkins.${var.public_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.httpd.public_ip]
}

resource "aws_route53_record" "jenkinspub" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "machine-jenkins.${var.public_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jenkins.public_ip]
}

resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "jenkins"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jenkins.private_ip]
}


