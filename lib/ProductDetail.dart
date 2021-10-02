class ProductDetails {
  String name;
  double low, med, high, selected, vat;
  int originalIndex;

  ProductDetails(
      {this.name,
      this.low,
      this.med,
      this.high,
      this.selected,
      this.vat,
      this.originalIndex});
  Map<String, dynamic> toJson() => {
        "name": name,
        "low": low.toString(),
        "med": med.toString(),
        "high": high.toString(),
      };
  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    var name = json['name'];
    var low = json['low'] ?? '0';
    var med = json['med'] ?? '0';
    var high = json['high'] ?? '0';

    return new ProductDetails(
      name: name.toUpperCase(),
      low: double.parse(low.replaceAll(',', '')),
      med: double.parse(med.replaceAll(',', '')),
      high: double.parse(high.replaceAll(',', '')),
    );
  }
}
