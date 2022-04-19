#### 以下のような1次元配列の形に整形
# secrets = [
#   {
#     "k" = "access-key"
#     "k2" = "id"
#     "v" = "xxx"
#   },
#   {
#     "k" = "access-key"
#     "k2" = "secret"
#     "v" = "yyy"
#   },
# ...
# ]
locals {
  secrets = flatten([
      for k,v in var.secrets : [
         for k2,v2 in v : {
           k = k
           k2 = k2
           v = v2
          }
      ]
    ]
  )
}

## 整形した1次元配列をループしてSSMパラメータストアに登録
resource "aws_ssm_parameter" "secrets" {

  for_each = { for s in local.secrets : "${s.k}/${s.k2}" => s.v}

  name   = "/secrets/${each.key}"
  value  = each.value
  type   = "SecureString"
}
