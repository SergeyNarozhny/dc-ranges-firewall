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
На текущий момент Netbox API token захардкожен как внутренняя переменная модуля - netbox_api_token.

Параметры на входе:
- vpc_self_link - self_link или name VPC, в которой создается firewall
- vpc_name - VPC name, который пойдет в description = имя фаера, по умолчанию = "common"
- direction ("INGRESS", "EGRESS") - тип фаера, по умолчанию = "INGRESS"
- allow - блок allow фаера
- target_tags - блок target_tags фаера
- custom_source_range (опционально) - дополнительный массив source_ranges, который добавится к общему блоку ip rages наших ЦОД

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
  custom_source_range = ["10.70.0.0/28"]
  target_tags = ["test"]
}
```

## Outputs
```
- dc_ranges_firewall.resource
```
