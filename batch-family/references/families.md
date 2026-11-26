# 成族样例（可增补）

本表是**样例**，不是全集。其它仓库（MES、小程序、网页、上位机）按同样方式归族：结构同构 → 一族；仅业务文案不同 → 单点。

## 通序 ERP（jshERP-web）常见族

| 族名 | 典型路径 | 注意 |
| --- | --- | --- |
| 往来单位弹窗 | `views/system/modules/VendorModal.vue`、`CustomerModal.vue`（可扩 Account/Member/Depot 等） | 字段名常不同，如 `allNeedPay` vs `allNeedGet` |
| 单据列表引导 | `views/bill/**/*List.vue` + `views/bill/mixins/BillListMixin.js` | 优先改 mixin |
| 财务列表引导 | `views/financial/**/*List.vue` + `views/financial/mixins/FinancialListMixin.js` | 与单据引导成对时两边都要 |
| 列表清空即查 | 各业务 `*List.vue` / 共用 `JeecgListMixin.js` | 能改 mixin 就不要只改一页 |
| 成功/失败提示文案 | 各 Modal / List 的 `$message` | 按「动词+对象+结果」整族替换 |

## 归族口诀

1. 同一交互、多份拷贝 → 整族。  
2. 只有一边有业务规则 → 单点。  
3. 先找 mixin / 公共组件，再散落文件。  
4. 新仓库第一次批量时，在回报里写下族名与路径，便于下次补进本表。
