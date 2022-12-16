# DC Ranges Firewall
Кастомный фаер GCP, который работает по схеме source_ranges - target_tags.
Текущая версия собирает prefixes из Netbox со следующих API endpoints:
- https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-hz
- https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-eq
- https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-lw
- https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-wz
- https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-sc-ams3-gl
- https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-sc-ams3-eu

## Params
На текущий момент Netbox API token захардкожен как внутренняя переменная модуля - netbox_api_token. К финальному source_ranges можно добавлять как свои блоки ip (custom_source_ranges), так и CIDR subnetworks через их имена (custom_subnets).

Параметры на входе:
- vpc_self_link - self_link или name VPC, в которой создается firewall
- vpc_name - VPC name, который пойдет в description = имя фаера, по умолчанию = "common"
- direction ("INGRESS", "EGRESS") - тип фаера, по умолчанию = "INGRESS"
- custom_source_ranges (опционально) - дополнительный массив source_ranges, который добавится к общему блоку
- custom_subnets (опционально, массив имен subnetworks из vpc_name) - дополнительный массив source_ranges из subnetworks CIDR, который добавится к общему блоку
- allow - блок allow фаера
- target_tags - блок target_tags фаера

## Usage example
### Example 1, открываем порт 8080 для тега test со всех адресов наших ЦОД
```
module "dc_ranges_firewall" {
  source = "git@gitlab.fbs-d.com:terraform/modules/dc-ranges-firewall.git"

  vpc_self_link = "common"
  allow = {
    protocol = "tcp"
    ports    = ["8080"]
  }
  target_tags = ["test"]
}
```
### Example 2, открываем порт 8080 для тега test со всех адресов наших ЦОД + 10.70.0.0/28
```
module "dc_ranges_firewall" {
  source = "git@gitlab.fbs-d.com:terraform/modules/dc-ranges-firewall.git"

  vpc_self_link = "common"
  allow = {
    protocol = "tcp"
    ports    = ["8080"]
  }
  custom_source_ranges = ["10.70.0.0/28"]
  target_tags = ["test"]
}
```
### Example 3, открываем порт 8080 для тега test со всех адресов наших ЦОД + 10.70.0.0/28 + cidr_range "stage-dmz-ew1" subnetwork
```
module "dc_ranges_firewall" {
  source = "git@gitlab.fbs-d.com:terraform/modules/dc-ranges-firewall.git"

  vpc_self_link = "common"
  allow = {
    protocol = "tcp"
    ports    = ["8080"]
  }
  custom_source_ranges = ["10.70.0.0/28"]
  custom_subnets = ["stage-dmz-ew1"]
  target_tags = ["test"]
}
```

## Outputs
```
- dc_ranges_firewall.resource
```
