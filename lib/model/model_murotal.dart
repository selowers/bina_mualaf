class ModelBacaanSuara {
  int? id;
  String? name;
  String? latin;
  String? terjemahan;
  String? suara;

  ModelBacaanSuara({
    this.id,
    this.name,
    this.latin,
    this.terjemahan,
    this.suara,
  });

  factory ModelBacaanSuara.fromJson(Map<String, dynamic> json) {
    return ModelBacaanSuara(
      id: json['id'],
      name: json['name'],
      latin: json['latin'],
      terjemahan: json['terjemahan'],
      suara: json['suara'],
    );
  }
}
