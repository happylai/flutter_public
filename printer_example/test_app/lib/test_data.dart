class TempletaJSon {
  static Map<String, dynamic> size50() {
    return {
      "width": "50",
      "height": "30",
      "layout": [
        {
          "fieldType": "barcode",
          "field": "barcode",
          "left": "0",
          "top": "1",
          "width": "40",
          "height": "9",
          "hideText": 0
        },
        {
          "field": "barcode",
          "left": "0",
          "top": "11",
          "width": "40",
          "height": "2.5",
          "fontSize": "2.5",
          "description": "商品唯一码"
        },
        {
          "field": "supplierName",
          "left": "38",
          "top": "2",
          "width": "10",
          "height": "12",
          "fontSize": "3",
          "description": "供货商名称"
        },
        {
          "field": "pickNo",
          "left": "1",
          "top": "14",
          "width": "30",
          "height": "5",
          "fontSize": "5",
          "description": "拣货码"
        },
        {
          "field": "expressName",
          "left": "31",
          "top": "13",
          "width": "17",
          "height": "6",
          "fontSize": "3",
          "description": "快递公司",
          "textAlign": "right",
          "textAlignVertical": "center"
        },
        {
          "field": "spuGoodsNoSkuName",
          "left": "0",
          "top": "19.5",
          "width": "48",
          "height": "3",
          "fontSize": "3",
          "description": "货号+规格名称",
          "textAlignVertical": "center"
        },
        {
          "field": "goodsNo",
          "left": "0",
          "top": "23",
          "width": "48",
          "height": "3",
          "fontSize": "3",
          "description": "商家编码",
          "textAlignVertical": "center"
        },
        {
          "field": "payTime",
          "left": "1",
          "top": "26.6",
          "width": "23",
          "height": "3",
          "fontSize": "2",
          "description": "付款时间"
        },
        {
          "field": "lastPrintTime",
          "left": "25.5",
          "top": "26.6",
          "width": "23",
          "height": "3",
          "fontSize": "2",
          "description": "打印时间"
        }
      ]
    };
  }

  static Map<String, dynamic> size60(){
    return {
      "width": "60",
      "height": "40",
      "layout": [
        {
          "fieldType": "barcode",
          "field": "barcode",
          "left": "0",
          "top": "1",
          "width": "40",
          "height": "12",
          "hideText": 0
        },
        {
          "field": "barcode",
          "left": "0",
          "top": "14",
          "width": "40",
          "height": "2.5",
          "fontSize": "2.5",
          "description": "商品唯一码"
        },
        {
          "field": "supplierName",
          "left": "40",
          "top": "2",
          "width": "18",
          "height": "12",
          "fontSize": "3",
          "description": "供货商名称"
        },
        {
          "field": "pickNo",
          "left": "1",
          "top": "18",
          "width": "26",
          "height": "7.12",
          "fontSize": "5",
          "description": "拣货码"
        },
        {
          "field": "expressName",
          "left": "27",
          "top": "17",
          "width": "30",
          "height": "6",
          "fontSize": "3",
          "description": "快递公司",
          "textAlign": "right",
          "textAlignVertical": "center"
        },
        {
          "field": "spuGoodsNoSkuName",
          "left": "0",
          "top": "23.5",
          "width": "58",
          "height": "6",
          "fontSize": "3",
          "description": "货号+规格名称",
          "textAlignVertical": "center"
        },
        {
          "field": "goodsNo",
          "left": "0",
          "top": "30",
          "width": "58",
          "height": "6",
          "fontSize": "3",
          "description": "商家编码",
          "textAlignVertical": "center"
        },
        {
          "field": "payTime",
          "left": "1",
          "top": "36",
          "width": "28",
          "height": "6",
          "fontSize": "2",
          "description": "付款时间"
        },
        {
          "field": "lastPrintTime",
          "left": "31",
          "top": "36",
          "width": "28",
          "height": "6",
          "fontSize": "2",
          "description": "打印时间"
        }
      ]
    };
  }

  static Map<String, dynamic> dataJson(){
    return {
      "barcode": "FD12312",
      "supplierName": "雪雪供货商",
      "pickNo": "A12-3",
      "expressName": "京东快递",
      "goodsNo": "b2324",
      "payTime": "2021-06-10",
      "lastPrintTime": "2021-06-08",
      "spuGoodsNo": "8923478",
      "skuName": "紫色",
    };
  }
}