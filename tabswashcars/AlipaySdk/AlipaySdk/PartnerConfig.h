//
//  PartnerConfig.h
//  AlipaySdkDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

#ifndef MQPDemo_PartnerConfig_h
#define MQPDemo_PartnerConfig_h

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088701804028516"
//收款支付宝账号
#define SellerID  @"2088701804028516"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY @""

//商户私钥，自助生成
#define PartnerPrivKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKRwMfbxNxj4HsF+dbwguxwKIzSMxmX7eb7POwTWOJOPQ+aisX7xO8SlD2W1I4weq/zpLF2l6irYicHOfmya7+Ojmb7fNrTTHsx+xTX+AFpIXs0s+pkxHp/T4fSd2cnWI/gJ6N6TgISRBEQOfAYJSlGVMmiCgn7Pq6I0O4kvSOrzAgMBAAECgYB66lKu4AfrZiy3PiwLf/vdLca7FS+IM74BXy4io26O/lwnHh3HYdLnXupvgEMeDh9JYZKEPe0YMdxnPk9KJ1aAg3ePWcSNUPHujgIlZZEOoMgMFbfHZZcPitq4YMsf+QROi6o1BXBeQ/iGClJboh3QsruEtqPFZxGWbDso/JdnQQJBANQMd7td36a5GqRgB3r7LmVA/dwbOWt11eQmSQ6qdWnO0gLe5aQZpVN1tROTVGZn5VZuM6IrVTRY82umUh3amnkCQQDGhXdgnN3XIzRkpQB8FqU4TaxgrQ34oQx7WpRRUHph5oggM8u+m1ceKrGqEx3uwUwyqZQ0ONT56ijZFok9SJXLAkEAu+K0MFOUOLDo116zIhfv2w3EIcQJk5rcQ4Rc1V7aHD+CO8LubQHASHwSTt8LOJW0Umng3D9TBsgOH4NGXWd12QJAH357AtPACepm3HSk0ArTqUwBRdEOf1wlW8hx8TiAQdnNzLYK47FHL9z8FIw12nPF/9+RSHufpgo08sO1gAhs4wJATpS64SIB6ltDdn5RHe/sLsTIEwdmN/creRomy/A8swejJPdJSpQunM7so4UCPD+eiumRaxhCafrzDq/DWgyPDA=="


//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"

#endif
