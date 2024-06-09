class BarcodeImgLinkProvider{
  static String barcodeImg({required String barcode}){
    return "https://barcodeapi.org/api/${barcode}";
  }
}